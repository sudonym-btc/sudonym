import * as https from 'https';
import * as fs from 'fs';
import axios from 'axios';
import { getConfig } from '../../config/config';
import { Injectable, Logger } from '@nestjs/common';
import { v4 as uuid } from 'uuid';
import * as bolt11 from 'bolt11';

@Injectable()
export class LightningNodeService {
	private readonly logger = new Logger(LightningNodeService.name);

	private macaroon;
	private url = getConfig().lightningREST;
	private info;
	private peers;
	private connectedChannels;

	calcHopFee(chann, amount) {
		return (
			Number(chann.base_fee_millisatoshi) +
			Math.ceil((chann.fee_per_millionth / 1000000) * amount)
		);
	}

	convertChannelsToRoute(inv = null) {
		const circle = this.connectedChannels[0];
		this.logger.debug('Circular payment along route', circle);
		const firstAmount = circle
			.reverse()
			.reduce(
				(acc, curr) => acc + this.calcHopFee(curr, acc),
				Number(inv?.millisatoshis)
			);
		let totalDelay =
			3 +
			circle.reduce((acc, curr) => acc + Number(curr.delay), 0) +
			circle[circle.length - 1].delay;

		return circle.reduce((acc, curr, index) => {
			const lastRouteItem = acc.length ? acc[acc.length - 1] : null;
			const lastNodeId = lastRouteItem?.id || this.info.id;
			const lastAmount = Number(
				lastRouteItem?.amount_msat || firstAmount
			);
			const id =
				curr.destination == lastNodeId ? curr.source : curr.destination;

			return [
				...acc,
				{
					id,
					channel: curr.short_channel_id,
					direction: curr.source < curr.destination ? 0 : 1,
					amount_msat: (
						lastAmount - this.calcHopFee(curr, lastAmount)
					).toString(),
					delay: (totalDelay -= curr.delay),
					style: 'tlv',
				},
			];
		}, []);
	}

	async loadInfo() {
		this.logger.verbose('Loading lightning node information.');

		this.info = await this.getInfo();
		this.connectedChannels = await Promise.all(
			await this.listChannels().then((i) =>
				i
					.filter(ch => ch.short_channel_id)
					.map((ch) => this.getChannel(ch.short_channel_id))
			)
		);
		this.peers = await this.listPeers();

		if (this.info.warning_lightningd_sync) {
			this.logger.error(this.info.warning_lightningd_sync);
		}

		this.logger.verbose(
			`Loaded lightning node information. ${this.info.id}, channels: ${this.connectedChannels.length}, peers: ${this.peers.length}`
		);
		if (this.connectedChannels.length == 0) {
			this.logger.warn('0 connected channels. Payments not possible');
		}
	}

	async onModuleInit() {
		try {
			this.macaroon = Buffer.from(
				fs.readFileSync(getConfig().macaroonFile)
			).toString('base64');

			this.loadInfo();

			setInterval(() => {
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
		return this.makeRequest({
			path: '/v1/peer/listPeers',
		});
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

	async createInvoice(amount, label = null, description = null) {
		return this.makeRequest({
			path: '/v1/invoice/genInvoice',
			method: 'POST',
			data: {
				amount,
				label: label || uuid(),
				description: description || 'test-description',
			},
		});
	}

	async getFees(pubkey, amount = 0) {
		const route = await this.getRoute(pubkey, amount);
		const first = route[0];
		const last = route.pop();
		if (!first || !last) {
			return 0;
		}
		return first.msatoshi - last.msatoshi;
	}

	async getRoute(pubkey, amount = 0) {
		return this.makeRequest({
			path: '/v1/network/getRoute/' + pubkey + '/' + amount,
		});
	}

	async pay(invoice) {
		const inv = bolt11.decode(invoice);

		// Selfpayments must be routed manually for core-ln
		if (inv.payeeNodeKey == this.info.id) {
			const circleRoute = this.convertChannelsToRoute(inv);
			this.logger.debug(
				'Routing local payment',
				circleRoute,
				inv.tagsObject.payment_hash,
				inv.millisatoshis,
				invoice,
				inv.tagsObject.payment_secret
			);
			return this.rpc('sendpay', [
				circleRoute,
				inv.tagsObject.payment_hash,
				'selfpaymentlabel',
				inv.millisatoshis,
				invoice,
				inv.tagsObject.payment_secret,
			]);
		}

		this.logger.debug('Making payment to ' + invoice);

		return this.makeRequest({
			path: '/v1/pay',
			method: 'POST',
			data: {
				invoice,
				retry_for: 20, //seconds
			},
		});
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
			data,
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
		return this.makeRequest({
			path: '/v1/pay/decodePay/' + invoice,
			method: 'GET',
		});
	}

	async makeRequest(options) {
		const response = await axios({
			url: this.url + options.path,
			method: 'GET',
			httpsAgent: new https.Agent({
				rejectUnauthorized: false,
			}),
			headers: {
				macaroon: this.macaroon,
			},
			...options,
		}).catch((e) => {
			this.logger.error('LIGHTNING ERROR', this.macaroon);
			throw e;
		});
		return response.data;
	}
}
