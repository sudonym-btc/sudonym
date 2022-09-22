import { BaseClass } from './base-class';

export class Receiver extends BaseClass {
	constructor(
		public id: number,
		public parentId: number | null,
		public potId: number,
		public type: string,
		public amount: number,
		public amountCurrency: string,
		public data: string,
		public lnurlId: string | null,
		public createdAt: Date
	) {
		super();
	}

	static fromJson(json: Object): Receiver {
		return new Receiver(
			json['id'],
			json['parentId'],
			json['potId'],
			json['type'],
			json['amount'],
			json['amountCurrency'],
			json['data'],
			json['lnurlId'],
			json['createdAt']
		);
	}

	toJson(): any {
		return {
			id: this.id,
			parentId: this.parentId,
			potId: this.potId,
			type: this.type,
			amount: this.amount,
			amountCurrency: this.amountCurrency,
			data: this.data,
			lnurlId: this.lnurlId,
			createdAt: this.createdAt,
		};
	}
}
