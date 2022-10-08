export class SettlementTransaction {
	constructor(public transactionId: number, public settlementId: number) {}

	static fromJson(json: any): SettlementTransaction {
		return new SettlementTransaction(
			json['transactionId'],
			json['settlementId']
		);
	}

	toJson(): any {
		return {
			transactionId: this.transactionId,
			settlementId: this.settlementId,
		};
	}
}
