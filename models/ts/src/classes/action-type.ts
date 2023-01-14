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
			isLnUrl,
			isLnAddress,
			isBolt11,
			isBolt12,
			isOnChain,
			comment
		);
	}
}
