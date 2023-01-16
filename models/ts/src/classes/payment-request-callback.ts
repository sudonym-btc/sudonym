export class PaymentRequestCallback {
	constructor(
		public pr: string,
		public disposable?: boolean | null,
		public routes?: [] | null,
		public successAction?: {
			tag: string;
			message: string;
		} | null
	) {}
}
