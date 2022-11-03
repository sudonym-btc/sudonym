import { LightningNodeService } from 'service/lightning-node/lightning-node.service';
import * as bolt11 from 'bolt11';
import { randomBytes } from 'crypto';

export class MockLightningNodeService extends LightningNodeService {
	pays = [];

	findCircular(): Promise<any> {
		throw new Error('Method not implemented.');
	}
	async onModuleInit(): Promise<void> {}
	getInfo(): Promise<any> {
		throw new Error('Method not implemented.');
	}
	listPeers(): Promise<any> {
		throw new Error('Method not implemented.');
	}
	listChannels(): Promise<any> {
		throw new Error('Method not implemented.');
	}
	getInvoices(): Promise<any> {
		throw new Error('Method not implemented.');
	}
	async createInvoice(
		amount: any,
		label?: any,
		description?: any
	): Promise<any> {
		const obj = bolt11.encode(
			{
				complete: true,
				millisatoshis: amount,
				tags: [
					{
						tagName: 'payment_hash',
						data: 'qwertyuiop',
					},
				],
			},
			true
		);
		return {
			...obj,
			bolt11: bolt11.sign(obj, randomBytes(32)).paymentRequest,
		};
	}
	getFees(pubkey: any, amount?: number): Promise<number> {
		throw new Error('Method not implemented.');
	}
	getRoute(pubkey: any, amount?: number): Promise<any> {
		throw new Error('Method not implemented.');
	}

	pay = jest.fn(async (invoice) => {
		const pay = {
			payment_preimage: 'mock',
			payment_hash: '543543543543543543534534543543',
			created_at: Date.now().valueOf() / 1000,
			parts: 1,
			partid: 1,
			amount_msat: 123,
			amount_sent_msat: 123,
			status: 'pending',
			destination: 'randomnode',
		};
		this.pays.push(pay);
		return pay;
		// payment_preimage (secret): the proof of payment: SHA256 of this payment_hash (always 64 characters)
		// payment_hash (hash): the hash of the payment_preimage which will prove payment (always 64 characters)
		// created_at (number): the UNIX timestamp showing when this payment was initiated
		// parts (u32): how many attempts this took
		// amount_msat (msat): Amount the recipient received
		// amount_sent_msat (msat): Total amount we sent (including fees)
		// status (string): status of payment (one of “complete”, “pending”, “failed”)
		// destination (pubkey, optional): the final destination of the payment
	}) as any;

	async listSendPays(bolt11, hash) {
		return this.pays.filter((i) => i.payment_hash == hash);
	}

	createOffer(amount: any, description?: any): Promise<any> {
		throw new Error('Method not implemented.');
	}
	fetchOfferInvoice(offer: any): Promise<any> {
		throw new Error('Method not implemented.');
	}
	generateOnChainAddress(): Promise<any> {
		throw new Error('Method not implemented.');
	}
	withdrawOnChain = jest.fn(async (invoice) => {}) as any;

	rpc = jest.fn(
		async (method: any, params: any) => 'Method not implemente'
	) as any;

	decodeInvoice(invoice: any): Promise<any> {
		throw new Error('Method not implemented.');
	}
	makeRequest(options: any): Promise<any> {
		throw new Error('Method not implemented.');
	}
}
