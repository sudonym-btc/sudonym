export class ActionType {
	constructor(
		public type: 'pay' | 'withdraw',
		public originalAddress: string,
		public isLnUrl: boolean | null = false,
		public isLnAddress: boolean | null = false,
		public isBolt11: boolean | null = false,
		public isBolt12: boolean | null = false,
		public isOnChain: boolean | null = false
	) {}
}
