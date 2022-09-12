import { BaseClass } from './base-class';

export class Receiver extends BaseClass {

	constructor(
        public id: number,
        public potId: number,
        public type: string,
        public amount: number,
        public amountCurrency: string,
        public data: string,
        public createdAt: Date
	) {
		super();
	}

	static fromJson(json: Object): Receiver {
		return new Receiver(
			json['id'],
			json['potId'],
			json['type'],
			json['amount'],
			json['amountCurrency'],
			json['data'],
			json['createdAt']
		);
	}

	toJson() {
		return {
			id: this.id,
			potId: this.potId,
			type: this.type,
			amount: this.amount,
			amountCurrency: this.amountCurrency,
			data: this.data,
			createdAt: this.createdAt
		};
	}
}