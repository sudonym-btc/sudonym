import { BaseClass } from './base-class';

export class Offer extends BaseClass {
	constructor(
		public id: string,
		public potId: number,
		public active: boolean,
		public amount: number | null,
		public bolt12: string,
		public bolt12Unsigned: string
	) {
		super();
	}

	static fromJson(json: Object): Offer {
		return new Offer(
			json['id'],
			json['potId'],
			json['active'],
			json['amount'],
			json['bolt12'],
			json['bolt12Unsigned']
		);
	}
	toJson() {
		return {
			id: this.id,
			potId: this.potId,
			active: this.active,
			amount: this.amount,
			bolt12: this.bolt12,
			bolt12Unsigned: this.bolt12Unsigned,
		};
	}
}
