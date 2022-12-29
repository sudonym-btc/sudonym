import { BaseClass } from './base-class';
import * as PotUserModel from './pot-user';
//todo: add polyfill for toList function needed in dart to js too
export class Pot extends BaseClass {
	constructor(
		public id: number | null,
		public name: string | null = '',
		public currency: string | null = 'BTC',
		public balance: number | null = 0,
		public spendableBalance: number | null = 0,
		public PotUser: PotUserModel.PotUser | any,
		public PotUsers: PotUserModel.PotUser[] | any
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
			json['PotUser'] != null
				? PotUserModel.PotUser.fromJson(json['PotUser'])
				: null,
			json['PotUsers'] != null
				? json['PotUsers']
						.map((i) => PotUserModel.PotUser.fromJson(i))
						.toList()
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
			PotUser: this.PotUser != null ? this.PotUser.toJson() : null,
			PotUsers: this.PotUsers.map((i) => i.toJson()).toList(),
		};
	}
}
