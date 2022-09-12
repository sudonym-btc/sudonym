import { BaseClass } from './base-class';

export class Transaction extends BaseClass {
	constructor(
		public id: number,
		public txid: string | null,
		public potId: number,
		public outgoing: boolean,
		public type: string | null,
		public originalAddress: string | null,
		public address: string | null,
		public description: string | null,
		public transactionId: number | null,
		public amount: number,
		public status: boolean | null,
		public currencyCode: string,
		public createdAt: Date
	) {
		super();
	}

	static fromJson(json: Object): Transaction {
		return new Transaction(
			json['id'],
			json['txid'],
			json['potId'],
			json['outgoing'],
			json['type'],
			json['originalAddress'],
			json['address'],
			json['description'],
			json['transactionId'],
			json['amount'],
			json['status'],
			json['currencyCode'],
			json['createdAt']
		);
	}

	toJson() {
		return {
			id: this.id,
			txid: this.txid,
			potId: this.potId,
			outgoing: this.outgoing,
			type: this.type,
			originalAddress: this.originalAddress,
			address: this.address,
			description: this.description,
			transactionId: this.transactionId,
			amount: this.amount,
			status: this.status,
			currencyCode: this.currencyCode,
			createdAt: this.createdAt,
		};
	}
}
