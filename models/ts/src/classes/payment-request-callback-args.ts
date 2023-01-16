export class PaymentRequestCallbackArgs {
	constructor(
		public amount: number,
		public comment?: string | null,
		public payerData?: {
			email?: string;
			name?: string;
			pubkey?: string;
			identifier?: string;
		} | null
	) {}
}
