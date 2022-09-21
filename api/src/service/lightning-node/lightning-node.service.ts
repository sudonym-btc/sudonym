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

	private macaroon = Buffer.from(
		fs.readFileSync(getConfig().macaroonFile)
	).toString('base64');
	private url = getConfig().lightningREST;
	private info;
	private peers;
	private connectedChannels;

	async findCircular() {
		const validEntryAndExists = [];
		for (const outgoing of this.connectedChannels) {
			for (const incoming of this.connectedChannels) {
				if (outgoing == incoming) continue;
				validEntryAndExists.push({ outgoing, incoming });
			}
		}

		const validEntryExitIds = validEntryAndExists.map((e) => [
			e.outgoing.id,
			e.incoming.id,
		]);

		const channels = (await this.rpc('listchannels', [])).channels;

		const circles = [];
		const relevantChannels = channels.filter((c) => {
			const vv = validEntryExitIds.find((v) => {
				return (
					(v[0] == c.source && v[1] == c.destination) ||
					(v[0] == c.destination && v[1] == c.source)
				);
			});
			if (vv) {
				const circle = [
					this.connectedChannels.find((c) => c.id == vv[0]),
					c,
					this.connectedChannels.find((c) => c.id == vv[1]),
				];
				circles.push(circle);
			}
			return !!vv;
		});

		// @todo: order by capacity

		return circles[0];
	}

	async onModuleInit() {
		try {
			this.logger.verbose('Loading lightning node information.');

			this.info = await this.getInfo();
			this.connectedChannels = await this.listChannels();
			this.peers = await this.listPeers();

			this.logger.verbose(
				`Loaded lightning node information. ${this.info.id}, channels: ${this.connectedChannels.length}, peers: ${this.peers.length}`
			);
			if(this.connectedChannels.length == 0) {
				this.logger.warn('0 connected channels. Payments not possible');
			}
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
		return 1000;
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
			const circle = await this.findCircular();
			let blockoffset = 3 + (circle.length + 1) * 6;
			this.logger.debug('Circular payment along route', circle);
			let lastNodeId = '';
			const circleRoute = circle.map((channel, index) => ({
				id:
					index + 1 == circle.length
						? this.info.id
						: (lastNodeId =
								channel.id ||
								(channel.destination != lastNodeId
									? channel.destination
									: channel.source)),
				channel: channel.short_channel_id,
				direction: index < 2 ? 1 : 0,
				amount_msat: (
					parseInt(inv.millisatoshis) +
					circle.length -
					index -
					1
				).toString(),
				delay: (blockoffset -= 6),
				style: 'tlv',
			}));
			this.logger.debug(
				circleRoute,
				inv.tagsObject.payment_hash,
				'selfpaymentlabel',
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

	async withdrawOnChain() {
		return this.makeRequest({
			path: '/v1/withdraw',
			method: 'POST',
			data: {},
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
