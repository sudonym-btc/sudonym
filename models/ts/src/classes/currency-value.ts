export class CurrencyValue {
	constructor(public amount: number, public currency: string) {}

	static fromJson(json: Object): CurrencyValue {
		return new CurrencyValue(json['amount'], json['currency']);
	}

	toJson(): any {
		return {
			amount: this.amount,
			currency: this.currency,
		};
	}
}
