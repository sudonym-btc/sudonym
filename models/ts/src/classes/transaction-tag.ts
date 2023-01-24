import { BaseClass } from './base-class';

export class TransactionTag extends BaseClass {
	constructor(
		public id: number,
		public transactionId: number | null,
		public tagId: number | null
	) {
		super();
	}

	static fromJson(json: Object): TransactionTag {
		return new TransactionTag(
			json['id'],
			json['transactionId'],
			json['tagId']
		);
	}

	toJson(): any {
		return {
			id: this.id,
			transactionId: this.transactionId,
			tagId: this.tagId,
		};
	}
}

export const TRANSACTION_TAGS = {
	1: 'roundup',
};
