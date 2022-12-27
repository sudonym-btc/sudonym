import { BaseClass } from './base-class';

export class BillSplitParticipant extends BaseClass {
	constructor(
		public id: number | null,
		public billSplitId: number | null,
		public amount: number | null = 0,
		public amountPaid: number | null = 0,
		public paid: boolean | null
	) {
		super();
	}

	static fromJson(json: Object): BillSplitParticipant {
		return new BillSplitParticipant(
			json['id'],
			json['billSplitId'],
			json['amount'],
			json['amountPaid'],
			json['paid']
		);
	}

	toJson(): any {
		return {
			id: this.id,
			billSplitId: this.billSplitId,
			amount: this.amount,
			amountPaid: this.amountPaid,
			paid: this.paid,
		};
	}
}
