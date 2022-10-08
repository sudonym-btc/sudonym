import { BaseClass } from './base-class';

export class LightningTransaction extends BaseClass {
	constructor(
		public id: string,
		public preimage: string,
		public amount: number | null,
		public status: boolean | null
	) {
		super();
	}

	static fromJson(json: Object): LightningTransaction {
		return new LightningTransaction(
			json['id'],
			json['preimage'],
			json['amount'],
			json['status']
		);
	}
	toJson(): any {
		return {
			id: this.id,
			preimage: this.preimage,
			amount: this.amount,
			status: this.status,
		};
	}
}
