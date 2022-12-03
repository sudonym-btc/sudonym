import { HttpException, Inject, Injectable, Logger } from '@nestjs/common';
import { SATOSHIS } from '@sudonym/models';
import axios from 'axios';
import * as bolt11 from 'bolt11';
import * as fs from 'fs';
import * as https from 'https';
import {
	PayResponse,
	SendPayResponse,
	WaitSendPayResponse,
} from 'service/transaction-listener/lightning-events';
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

	// Lists onchain and in-channel funds
	async listFunds() {
		const funds = await this.makeRequest({
			path: '/v1/listFunds',
			method: 'GET',
		});

		this.logger.verbose(funds);

		return (
			(funds.outputs.reduce((acc, i) => acc + i.value, 0) +
				funds.channels.reduce((acc, i) => acc + i.channel_sat, 0)) /
			SATOSHIS
		);
	}

	async circularRoute(millisatoshis) {
		const channel =
			this.connectedChannels.find(
				(c) =>
					c.spendable_msatoshi >= millisatoshis &&
					c.state == 'CHANNELD_NORMAL'
			) || this.connectedChannels[0]; // Try sending with first channel if none fit filter and fail organically
		const firstChannelOut = channel.channels.find(
			(c) => c.source == this.info.id
		);
		const firstChannelIn = channel.channels.find(
			(c) => c.source != this.info.id
		);
		this.logger.log('selfpayment', firstChannelIn, firstChannelOut);
		// Get route to current node from first peer which excludes the direct route
		const restHops = await this.getRoute(
			this.info.id,
			millisatoshis,
			20,
			firstChannelOut.delay,
			firstChannelOut.destination,
			null,
			[
				...this.connectedChannels
					.filter(
						(c) =>
							c.msatoshi_to_them -
								Math.max(
									c.their_channel_reserve_satoshis * 1000,
									c.our_channel_reserve_satoshis * 1000
								) <
							millisatoshis
					)
					.map((c) => [
						c.short_channel_id + '/1',
						c.short_channel_id + '/0',
					])
					.flat(), //exclude all incoming channels where they don't have enough to push to us.
				// should be handled by getroute, but doesn't seem to take into account reserve requirements https://github.com/ElementsProject/lightning/issues/5772
				firstChannelIn.short_channel_id +
					'/' +
					this.getDirection(firstChannelIn.source, this.info.id),
			]
		);
		this.logger.log([
			...this.connectedChannels
				.filter(
					(c) =>
						c.msatoshi_to_them -
							Math.max(
								c.their_channel_reserve_satoshis * 1000,
								c.our_channel_reserve_satoshis * 1000
							) <
						millisatoshis
				)
				.map((c) => [
					c.short_channel_id + '/1',
					c.short_channel_id + '/0',
				])
				.flat(), //exclude all incoming channels where they don't have enough to push to us.
			// should be handled by getroute, but doesn't seem to take into account reserve requirements https://github.com/ElementsProject/lightning/issues/5772
			firstChannelIn.short_channel_id +
				'/' +
				this.getDirection(firstChannelIn.source, this.info.id),
		]);
		this.logger.verbose('Got route back home', restHops);

		const secondChannel = (await this.getChannel(restHops[0].channel)).find(
			(c) => c.destination == restHops[0].id
		);
		let totalPlusFirstNodeFee =
			restHops[0].msatoshi +
			this.calcHopFee(secondChannel, restHops[0].msatoshi);
		totalPlusFirstNodeFee += this.calcHopFee(
			firstChannelIn,
			totalPlusFirstNodeFee
		);
		const firstHop = await this.getRoute(
			firstChannelIn.source,
			totalPlusFirstNodeFee,
			0,
			restHops[0].delay + firstChannelIn.delay
		);

		return [...firstHop, ...restHops];
	}

	async loadConnectedChannels() {
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
		if (this.connectedChannels.length == 0) {
			this.logger.warn('0 connected channels. Payments not possible');
		}
	}

	async loadInfo() {
		this.logger.verbose('Loading lightning node information.');

		this.info = await this.getInfo();
		await this.loadConnectedChannels();
		this.peers = await this.listPeers();
		this.logger.debug('peers', JSON.stringify(this.peers));

		if (this.info.warning_lightningd_sync) {
			this.logger.error(this.info.warning_lightningd_sync);
		}

		this.logger.log(
			`Loaded lightning node information. ${this.info.id}, channels: ${this.connectedChannels.length}, peers: ${this.peers.length}`
		);
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
			this.loadConnectedChannels(); // reload connected channels before choosing outgoing channel for self payment route calc
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

	async pay(invoice, amount): Promise<PayResponse | SendPayResponse> {
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

			const args = [
				circleRoute,
				inv.tagsObject.payment_hash,
				'selfpaymentlabel',
				!hasAmount
					? Math.round(amount)
					: inv.millisatoshis || inv.satoshis * 1000,
				invoice,
				inv.tagsObject.payment_secret,
				1,
			];

			this.logger.debug('Routing local payment', ...args);
			return this.rpc('sendpay', args);
		}

		this.logger.verbose('Making payment to ' + invoice);

		return this.rpc('pay', [
			invoice,
			!hasAmount ? Math.round(amount) : null,
			null, //[label]
			null, //[riskfactor]
			null, // [maxfeepercent],
			10, // [retry_for],
			null, // [maxdelay]
			null, //[exemptfee]
			null, //[localinvreqid]
			['758820x1587x1/0', '758820x1587x1/1'], //[exclude]
			null, //[maxfee]
			null, //[description]
		]);
	}

	async waitSendPay(
		payment_hash: string,
		timeout: number | null = null,
		partId?: number
	): Promise<WaitSendPayResponse> {
		return this.rpc('waitsendpay', [payment_hash, timeout, partId]);
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
