import { BaseClass } from './base-class';
import { PotUser } from './pot-user';

export class Pot extends BaseClass {
	constructor(
		public id: number | null,
		public name: string = '',
		public currency: string = 'BTC',
		public balance: number | null = 0,
		public spendableBalance: number | null = 0,
		public PotUsers: PotUser[] | null
	) {
		super();
	}

	static fromJson(json: Object): Pot {
		return new Pot(
			json['id'],
			json['name'],
			json['currency'],
			json['balance'],
			json['spendableBalance'],
			json['PotUsers']
				? json['PotUsers'].map((i) => PotUser.fromJson(i))
				: []
		);
	}

	toJson(): any {
		return {
			id: this.id,
			name: this.name,
			currency: this.currency,
			balance: this.balance,
			spendableBalance: this.spendableBalance,
			PotUsers: this.PotUsers,
		};
	}
}
