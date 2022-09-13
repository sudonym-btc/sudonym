import { BaseClass } from './base-class';

export class Pot extends BaseClass {
	constructor(
		public id: number | null,
		public name: string = '',
		public currency: string = 'BTC',
		public balance: number = 0,
		public spendableBalance: number = 0
	) {
		super();
	}

	static fromJson(json: Object): Pot {
		return new Pot(
			json['id'],
			json['name'],
			json['currency'],
			json['balance'],
			json['spendableBalance']
		);
	}

	toJson(): any {
		return {
			id: this.id,
			name: this.name,
			currency: this.currency,
			balance: this.balance,
			spendableBalance: this.spendableBalance,
		};
	}
}
