export class PaymentRequest {
	constructor(
		public tag = 'payRequest', // Type of LNURL
		public callback: string | null, // The URL from LN SERVICE which will accept the pay request parameters
		public maxSendable: number | null, // Max millisatoshi amount LN SERVICE is willing to receive
		public minSendable: number | null, // Min millisatoshi amount LN SERVICE is willing to receive, can not be less than 1 or more than `maxSendable`
		public metadata: string | null // Metadata json which must be presented as raw string here, this is required to pass signature verification at a later step
	) {}

	static fromJson(json: Object): PaymentRequest {
		return new PaymentRequest(
			json['tag'],
			json['callback'],
			json['maxSendable'],
			json['minSendable'],
			json['metadata']
		);
	}
	toJson() {
		return {
			tag: this.tag,
			callback: this.callback,
			maxSendable: this.maxSendable,
			minSendable: this.minSendable,
			metadata: this.metadata,
		};
	}
}
