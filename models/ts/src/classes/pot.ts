import { BaseClass } from './base-class';
import { PotUser } from './pot-user';
//todo: add polyfill for toList function needed in dart to js too
export class Pot extends BaseClass {
	constructor(
		public id: number | null,
		public name: string = '',
		public currency: string = 'BTC',
		public balance: number | null = 0,
		public spendableBalance: number | null = 0,
		public PotUsers: PotUser[] | any
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
			json['PotUsers'] != null
				? json['PotUsers'].map((i) => PotUser.fromJson(i)).toList()
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
			PotUsers: this.PotUsers.map((i) => i.toJson()).toList(),
		};
	}
}
