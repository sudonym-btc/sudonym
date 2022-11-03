export class Bolt11Received {
	label: string;
	bolt11: string;
	payment_hash: string;
	msatoshi: number;
	amount_msat: string;
	status: 'paid' | 'pending' | 'failed';
	pay_index: number;
	msatoshi_received: number;
	amount_received_msat: string;
	paid_at: number;
	payment_preimage: string;
	description: string;
	expires_at: number;
}
