import { BaseClass } from './base-class';

export class OnchainTransaction extends BaseClass {
	constructor(
		public id: string,
		public fromAddress: string | null,
		public toAddress: string | null,
		public amount: number | null,
		public blockHeight: number | null
	) {
		super();
	}

	static fromJson(json: Object): OnchainTransaction {
		return new OnchainTransaction(
			json['id'],
			json['fromAddress'],
			json['toAddress'],
			json['amount'],
			json['blockHeight']
		);
	}
	toJson(): any {
		return {
			id: this.id,
			fromAddress: this.fromAddress,
			toAddress: this.toAddress,
			amount: this.amount,
			blockHeight: this.blockHeight,
		};
	}
}
