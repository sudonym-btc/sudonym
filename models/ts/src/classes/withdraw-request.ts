export class WithdrawRequest {
	constructor(
		public tag = 'withdrawRequest', // type of LNURL
		public callback: string | null, // The URL which LN SERVICE would accept a withdrawal Lightning invoice as query parameter
		public k1: string | null, // Random or non-random string to identify the user's LN WALLET when using the callback URL
		public defaultDescription: string | null, // A default withdrawal invoice description
		public minWithdrawable: number | null, // Min amount (in millisatoshis) the user can withdraw from LN SERVICE, or 0
		public maxWithdrawable: number | null // Max amount (in millisatoshis) the user can withdraw from LN SERVICE, or equal to minWithdrawable if the user has no choice over the amounts
	) {}

	static fromJson(json: Object): WithdrawRequest {
		return new WithdrawRequest(
			json['tag'],
			json['callback'],
			json['k1'],
			json['defaultDescription'],
			json['minWithdrawable'],
			json['maxWithdrawable']
		);
	}

	toJson(): any {
		return {
			tag: this.tag,
			callback: this.callback,
			k1: this.k1,
			defaultDescription: this.defaultDescription,
			minWithdrawable: this.minWithdrawable,
			maxWithdrawable: this.maxWithdrawable,
		};
	}
}
