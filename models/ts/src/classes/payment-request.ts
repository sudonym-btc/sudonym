export class PaymentRequest {
	constructor(
		public tag = 'payRequest', // Type of LNURL
		public domain: string | null, // The URL from LN SERVICE which will accept the pay request parameters
		public callback: string | null, // The URL from LN SERVICE which will accept the pay request parameters
		public maxSendable: number | null, // Max millisatoshi amount LN SERVICE is willing to receive
		public minSendable: number | null, // Min millisatoshi amount LN SERVICE is willing to receive, can not be less than 1 or more than `maxSendable`
		public metadata: string | null, // Metadata json which must be presented as raw string here, this is required to pass signature verification at a later step
		public commentAllowed: number | null, // Metadata json which must be presented as raw string here, this is required to pass signature verification at a later step
		public payerData: {
			name?: {
				mandatory: boolean;
			};
			pubkey?: {
				mandatory: boolean;
			};
			identifier?: {
				mandatory: boolean;
			};
			email?: {
				mandatory: boolean;
			};
		} | null // When someone pays they can send the following fields to identify the payer
	) {}

	static fromJson(json: Object): PaymentRequest {
		return new PaymentRequest(
			json['tag'],
			json['domain'],
			json['callback'],
			json['maxSendable'],
			json['minSendable'],
			json['metadata'],
			json['commentAllowed'],
			json['payerData']
		);
	}
	toJson(): any {
		return {
			tag: this.tag,
			domain: this.domain,
			callback: this.callback,
			maxSendable: this.maxSendable,
			minSendable: this.minSendable,
			metadata: this.metadata,
			commentAllowed: this.commentAllowed,
			payerData: this.payerData,
		};
	}
}
