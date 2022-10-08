import { BaseClass } from './base-class';
import { Lnurl } from './lnurl';

export class Sender extends BaseClass {
	constructor(
		public id: number | null,
		public userId: string | null,
		public potId: number | null,
		public lnurl: Lnurl | null,
		public lnurlId: string | null,
		public type: string | null,
		public amount: number | null,
		public amountCurrency: string | null,
		public limitDay: number | null,
		public limitMonth: number | null,
		public limitYear: number | null,
		public limitMin: number | null,
		public limitMax: number | null,
		public data: string,
		public createdAt: Date | null
	) {
		super();
	}

	static fromJson(json: Object): Sender {
		return new Sender(
			json['id'],
			json['userId'],
			json['potId'],
			json['lnurl'] != null ? Lnurl.fromJson(json['lnurl']) : null,
			json['lnurlId'],
			json['type'],
			json['amount'],
			json['amountCurrency'],
			json['limitDay'],
			json['limitMonth'],
			json['limitYear'],
			json['limitMin'],
			json['limitMax'],
			json['data'],
			json['createdAt']
		);
	}

	toJson(): any {
		return {
			id: this.id,
			userId: this.userId,
			potId: this.potId,
			lnurl: this.lnurl != null ? this.lnurl.toJson() : null,
			lnurlId: this.lnurlId,
			type: this.type,
			amount: this.amount,
			amountCurrency: this.amountCurrency,
			limitDay: this.limitDay,
			limitMonth: this.limitMonth,
			limitYear: this.limitYear,
			limitMin: this.limitMin,
			limitMax: this.limitMax,
			data: this.data,
			createdAt: this.createdAt,
		};
	}
}
