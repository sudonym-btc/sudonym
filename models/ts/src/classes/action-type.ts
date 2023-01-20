export class ActionType {
	constructor(
		public type: 'pay' | 'withdraw',
		public originalAddress: string,
		public isLnUrl: boolean | null = false,
		public isLnAddress: boolean | null = false,
		public isBolt11: boolean | null = false,
		public isBolt12: boolean | null = false,
		public isOnChain: boolean | null = false,
		public comment: string | null = ''
	) {}
}

export class ActionTypeWithAmount extends ActionType {
	constructor(
		public type: 'pay' | 'withdraw',
		public originalAddress: string,
		public isLnUrl: boolean | null = false,
		public isLnAddress: boolean | null = false,
		public isBolt11: boolean | null = false,
		public isBolt12: boolean | null = false,
		public isOnChain: boolean | null = false,
		public comment: string | null = '',
		public minAmount: number | null,
		public maxAmount: number | null,
		public amount: number | null,
		public currency: string | null = 'BTC'
	) {
		super(
			'pay',
			originalAddress,
			isLnUrl != null ? isLnUrl : false,
			isLnAddress != null ? isLnAddress : false,
			isBolt11 != null ? isBolt11 : false,
			isBolt12 != null ? isBolt12 : false,
			isOnChain != null ? isOnChain : false,
			comment
		);
	}

	toJson(): any {
		return {
			type: this.type,
			originalAddress: this.originalAddress,
			isLnAddress: this.isLnAddress,
			isLnUrl: this.isLnUrl,
			isBolt11: this.isBolt11,
			isBolt12: this.isBolt12,
			isOnChain: this.isOnChain,
			amount: this.amount,
			comment: this.comment,
			minAmount: this.minAmount,
			maxAmount: this.maxAmount,
			currency: this.currency,
		};
	}
}
