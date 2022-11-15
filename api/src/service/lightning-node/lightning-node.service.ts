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
		this.logger.debug('Calculating fee', chann, amount, fee);
		return fee;
	}

	getDirection(from, to) {
		return from < to ? '0' : '1';
	}

	async circularRoute(millisatoshis) {
		const channel = this.connectedChannels.find(
			(c) =>
				c.spendable_msatoshi >= millisatoshis &&
				c.state == 'CHANNELD_NORMAL'
		);
		const outgoingChannel = channel.channels.find(
			(c) => c.destination != this.info.id
		);
		const incomingChannel = channel.channels.find(
			(c) => c.destination == this.info.id
		);
		console.log(outgoingChannel, incomingChannel);
		// Get route to current node from first peer which excludes the direct route
		const restHops = await this.getRoute(
			this.info.id,
			millisatoshis,
			0,
			200,
			outgoingChannel.destination,
			null,
			[
				outgoingChannel.short_channel_id +
					'/' +
					this.getDirection(
						outgoingChannel.destination,
						this.info.id
					),
			]
		);
		const secondHop = (await this.getChannel(restHops[0].channel)).find(
			(c) => c.destination == restHops[0].id
		);
		const firstHop = await this.getRoute(
			outgoingChannel.destination,
			restHops[0].msatoshi +
				this.calcHopFee(secondHop, restHops[0].msatoshi),
			0,
			restHops[0].delay + incomingChannel.delay
		);

		return [...firstHop, ...restHops];
	}

	async loadInfo() {
		this.logger.verbose('Loading lightning node information.');

		this.info = await this.getInfo();
		this.connectedChannels = await Promise.all(
			await this.listChannels().then((i) =>
				i
					.filter((ch) => ch.short_channel_id)
					.map((ch) =>
						this.getChannel(ch.short_channel_id).then((i) => ({
							...ch,
							channels: i,
						}))
					)
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
			try {
				peer.route = await this.getRoute(peer.id);
			} catch (e) {}
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
		// Get route to route hint for private nodes, or node_id for public nodes
		const destination =
			inv.tags?.find((t) => t.tagName == 'routing_info')?.data[0]
				.pubkey || inv.payeeNodeKey;
		// todo: take into account all route hints and add the extra fee!
		return this.getFees(destination, amount);
	}

	async getFees(pubkey, amount = 1000) {
		const route = await this.getRoute(pubkey, amount);
		// console.log(route);
		const first = route[0];
		const last = route.pop();
		if (!first || !last) {
			return 0;
		}
		return first.msatoshi - last.msatoshi;
	}

	async getRoute(
		pubkey,
		amount = 1000,
		riskfactor = 0,
		cltv = null,
		from_id = null,
		fuzz = null,
		exclude = null,
		maxhops = null
	) {
		if (pubkey == this.info.id && !from_id) {
			return await this.circularRoute(amount);
		}

		return (
			await this.rpc('getroute', [
				pubkey,
				amount,
				riskfactor,
				cltv,
				from_id,
				fuzz,
				exclude,
				maxhops,
			])
		).route;
	}

	async pay(invoice, amount) {
		const inv = bolt11.decode(invoice);
		let hasAmount = false;
		if (inv.millisatoshis || inv.satoshis) {
			hasAmount = true;
		}

		// Selfpayments must be routed manually for core-ln
		if (inv.payeeNodeKey == this.info.id) {
			const circleRoute = await this.getRoute(
				this.info.id,
				hasAmount ? Number(inv.millisatoshis) : amount
			);

			this.logger.debug(
				'Routing local payment',
				JSON.stringify(circleRoute),
				inv.tagsObject.payment_hash,
				hasAmount ? amount : null,
				invoice,
				inv.tagsObject.payment_secret,
				1
			);
			return this.rpc('sendpay', [
				circleRoute,
				inv.tagsObject.payment_hash,
				'selfpaymentlabel',
				hasAmount ? amount : null,
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
