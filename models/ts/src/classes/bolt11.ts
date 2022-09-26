export class Bolt11 {
	constructor(
		public millisatoshis: number,
		public network: {
			bech32: string;
			pubKeyHash: number;
			scriptHash: number;
			validWitnessVersions: number[];
		},
		public payeeNodeKey: string,
		public paymentRequest: string,
		public prefix: string,
		public recoveryFlag: number,
		public satoshis: number,
		public signature: string,
		public tags: { tagName: string; data: string }[],
		public timeExpireDate: number,
		public timeExpireDateString: string,
		public timestamp: number,
		public timestampString: string,
		public wordsTemp: string,
		public label?: string | null
	) {}

	static fromJson(json: Object): Bolt11 {
		return new Bolt11(
			json['millisatoshis'],
			json['network'],
			json['payeeNodeKey'],
			json['paymentRequest'],
			json['prefix'],
			json['recoveryFlag'],
			json['satoshis'],
			json['signature'],
			json['tags'],
			json['timeExpireDate'],
			json['timeExpireDateString'],
			json['timestamp'],
			json['timestampString'],
			json['wordsTemp']
		);
	}

	toJson(): any {
		return {
			millisatoshis: this.millisatoshis,
			network: this.network,
			payeeNodeKey: this.payeeNodeKey,
			paymentRequest: this.paymentRequest,
			prefix: this.prefix,
			recoveryFlag: this.recoveryFlag,
			satoshis: this.satoshis,
			signature: this.signature,
			tags: this.tags,
			timeExpireDate: this.timeExpireDate,
			timeExpireDateString: this.timeExpireDateString,
			timestamp: this.timestamp,
			timestampString: this.timestampString,
			wordsTemp: this.wordsTemp,
		};
	}
}
