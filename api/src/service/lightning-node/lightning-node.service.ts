import { HttpException, Inject, Injectable, Logger } from '@nestjs/common';
import axios from 'axios';
import * as bolt11 from 'bolt11';
import * as fs from 'fs';
import * as https from 'https';
import { v4 as uuid } from 'uuid';
import { Config } from '../../config/config';

@Injectable()
export class LightningNodeService {
	private readonly logger = new Logger(LightningNodeService.name);
	@Inject(Config) private readonly config: Config;

	private macaroon;
	private info;
	private peers;
	private connectedChannels;

	private interval;

	onModuleDestroy() {
		if (this.interval) clearInterval(this.interval);
	}

	calcHopFee(chann, amount) {
		const fee =
			Number(chann.base_fee_millisatoshi) +
			Math.ceil((chann.fee_per_millionth / 1000000) * amount);
		// this.logger.debug("Calculating fee", chann, amount, fee);
		return fee;
	}

	convertChannelsToRoute(millisatoshis) {
		const peer = this.peers.find(
			(p) =>
				p.route.length == 1 &&
				p.channels[0].spendable_msatoshi >= millisatoshis &&
				p.channels[0].receivable_msatoshi >= millisatoshis &&
				p.channels[0].htlc_minimum_msat <= millisatoshis
		);

		if (!peer) {
			throw new LightningError(
				'No route found',
				'No route found',
				400,
				400
			); // todo: adjust error
		}
		// Get channel that is big enough to send
		const circle = this.connectedChannels.find(
			(i) => i[0].short_channel_id == peer.channels[0].short_channel_id
		);
		this.logger.debug(
			'Circular payment along route',
			JSON.stringify(circle)
		);
		const fees = [];
		const firstAmount = circle.reverse().reduce((acc, curr) => {
			fees.push(this.calcHopFee(curr, acc));
			return acc + fees[fees.length - 1];
		}, Number(millisatoshis));
		let totalDelay =
			9 + // total cltv to be left with at end, this is default value for core-ln
			circle.reduce(
				(acc, curr) => acc + Number(curr.delay),
				-circle[0].delay
			);

		this.logger.debug('total delay', totalDelay);
		this.logger.debug('total fee', firstAmount - millisatoshis);
		this.logger.debug('fees', fees);
		this.logger.debug('first amount', firstAmount, millisatoshis);

		return {
			amount: firstAmount,
			route: circle.reduce((acc, curr, index) => {
				const lastRouteItem = acc.length ? acc[acc.length - 1] : null;
				const lastNodeId = lastRouteItem
					? lastRouteItem?.id
					: this.info.id;
				const lastAmount = lastRouteItem
					? lastRouteItem.msatoshi
					: firstAmount;
				const lastFee = fees[index];
				const id =
					curr.destination == lastNodeId
						? curr.source
						: curr.destination;

				this.logger.debug('lastAmount', lastAmount, 'fee', lastFee);

				const amount_msat = lastAmount - lastFee;
				return [
					...acc,
					{
						id,
						channel: curr.short_channel_id,
						direction: lastNodeId < id ? 0 : 1,
						msatoshi: amount_msat,
						amount_msat: amount_msat.toString() + 'msat',
						delay: (totalDelay -= curr.delay),
						style: 'tlv',
					},
				];
			}, []),
		};
	}

	async loadInfo() {
		this.logger.verbose('Loading lightning node information.');

		this.info = await this.getInfo();
		this.connectedChannels = await Promise.all(
			await this.listChannels().then((i) =>
				i
					.filter((ch) => ch.short_channel_id)
					.map((ch) => this.getChannel(ch.short_channel_id))
			)
		);
		this.logger.debug('channels', JSON.stringify(this.connectedChannels));
		this.peers = await this.listPeers();
		this.logger.debug('peers', JSON.stringify(this.peers));

		if (this.info.warning_lightningd_sync) {
			this.logger.error(this.info.warning_lightningd_sync);
		}

		this.logger.log(
			`Loaded lightning node information. ${this.info.id}, channels: ${this.connectedChannels.length}, peers: ${this.peers.length}`
		);
		if (this.connectedChannels.length == 0) {
			this.logger.warn('0 connected channels. Payments not possible');
		}
	}

	async onModuleInit() {
		try {
			this.macaroon = Buffer.from(
				fs.readFileSync(this.config.macaroonFile)
			).toString('base64');

			await this.loadInfo();
			this.interval = setInterval(() => {
				this.loadInfo();
			}, 5 * 60 * 1000); // refresh every 5 minutes
		} catch (e) {
			this.logger.error(e);
		}
	}

	async getInfo() {
		return this.makeRequest({
			path: '/v1/getinfo',
		});
	}
	async listPeers() {
		const peers = (await this.rpc('listpeers', [])).peers;
		for (const peer of peers) {
			peer.route = await this.getRoute(peer.id);
		}
		return peers;
	}

	async listChannels() {
		return this.makeRequest({
			path: '/v1/channel/listChannels',
		});
	}

	async getChannel(c) {
		return this.makeRequest({
			path: '/v1/network/listChannel/' + c,
		});
	}

	async getInvoices() {
		return this.makeRequest({
			path: '/v1/invoice/listInvoices',
		});
	}

	async createInvoice(
		amount,
		label = null,
		description = null,
		desc_hash = false,
		preimage = undefined
	) {
		if (amount == 0) amount = 'any';
		return this.rpc('invoice', [
			amount,
			label || uuid(),
			description || uuid(),
			null,
			null,
			preimage,
			null,
			null,
			desc_hash,
		]);
	}

	async getFeesInvoice(payreq, amount = 1000) {
		const inv = bolt11.decode(payreq);
		const destination =
			inv.tags.find((t) => t.tagName == 'routing_info')?.data[0].pubkey ||
			inv.payeeNodeKey;
		return this.getFees(destination, amount);
	}

	async getFees(pubkey, amount = 1000) {
		const route = await this.getRoute(pubkey, amount);
		const first = route[0];
		const last = route.pop();
		if (!first || !last) {
			return 0;
		}
		return first.msatoshi - last.msatoshi;
	}

	async getRoute(pubkey, amount = 1000) {
		if (pubkey == this.info.id) {
			return await this.convertChannelsToRoute(amount).route;
		}
		return this.makeRequest({
			path: '/v1/network/getRoute/' + pubkey + '/' + amount,
		});
	}

	async pay(invoice, amount) {
		const inv = bolt11.decode(invoice);
		let hasAmount = false;
		if (inv.millisatoshis || inv.satoshis) {
			hasAmount = true;
		}

		// Selfpayments must be routed manually for core-ln
		if (inv.payeeNodeKey == this.info.id) {
			const circleRoute = this.convertChannelsToRoute(
				hasAmount ? Number(inv.millisatoshis) : amount
			);
			this.logger.debug(
				'Routing local payment',
				JSON.stringify(circleRoute),
				inv.tagsObject.payment_hash,
				circleRoute.route[0].msatoshi,
				invoice,
				inv.tagsObject.payment_secret,
				1
			);
			return this.rpc('sendpay', [
				circleRoute.route,
				inv.tagsObject.payment_hash,
				'selfpaymentlabel',
				amount,
				invoice,
				inv.tagsObject.payment_secret,
				1,
			]);
		}

		this.logger.verbose('Making payment to ' + invoice);

		return this.makeRequest({
			path: '/v1/pay',
			method: 'POST',
			data: {
				invoice,
				amount: !hasAmount ? Math.round(amount) : null,
				retry_for: 20, //seconds
			},
		});
	}

	waitSendPay(payment_hash: string, timeout: number | null, partId: any) {
		return this.rpc('waitsendpay', [payment_hash, null, partId]);
	}

	async listSendPays(bolt11, payment_hash) {
		return (await this.rpc('listsendpays', [null, payment_hash])).payments;
	}

	async createOffer(amount, description = null) {
		return this.makeRequest({
			path: '/v1/offers/offer',
			method: 'POST',
			data: {
				amount,
				description: description || 'test-description-' + uuid(),
			},
		});
	}

	async fetchOfferInvoice(offer) {
		return this.makeRequest({
			path: '/v1/offers/fetchInvoice',
			method: 'POST',
			data: {
				offer,
			},
		});
	}

	async generateOnChainAddress() {
		return this.makeRequest({
			path: '/v1/newaddr',
			method: 'GET',
		});
	}

	async withdrawOnChain(data: { satoshis: number; address: string }) {
		return this.makeRequest({
			path: '/v1/withdraw',
			method: 'POST',
			data: {
				address: data.address,
				satoshis: Math.floor(data.satoshis),
			},
		});
	}

	async onChainFees() {
		return await this.makeRequest({
			path: '/v1/network/estimateFees',
			method: 'GET',
		});
	}

	async rpc(method, params) {
		return this.makeRequest({
			path: '/v1/rpc',
			method: 'POST',
			data: {
				method,
				params,
			},
		});
	}

	async decodeInvoice(invoice) {
		const inv = bolt11.decode(invoice);
		if (!inv.satoshis && inv.millisatoshis) {
			inv.satoshis = Number(inv.millisatoshis) / 1000;
		}
		return inv;
		// return this.makeRequest({
		// 	path: '/v1/pay/decodePay/' + invoice,
		// 	method: 'GET',
		// });
	}

	async makeRequest(options) {
		const response = await axios({
			url: this.config.lightningREST + options.path,
			method: 'GET',
			httpsAgent: new https.Agent({
				rejectUnauthorized: false,
			}),
			headers: {
				macaroon: this.macaroon,
			},
			...options,
		}).catch((e) => {
			this.logger.error('Lightning error', e, e.response?.data);
			if (e.response?.data?.error)
				throw new LightningError(
					e.response.data.error,
					e.response.data.error.message,
					500,
					e.response.data.error.code
				);
			throw new LightningError(e, e, e.statusCode, e);
		});
		return response.data;
	}
}

export class LightningError extends HttpException {
	constructor(public error, message, statusCode, public lightingErrorCode) {
		super(message, statusCode);
	}
}
