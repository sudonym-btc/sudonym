import { BaseClass } from './base-class';
import { BillSplitParticipant } from './bill-split-participant';

export class BillSplit extends BaseClass {
	constructor(
		public id: number | null,
		public transactionId: number | null,
		public currency: string = 'BTC',
		public amount: number | null = 0,
		public BillSplitParticipants: BillSplitParticipant[] | any
	) {
		super();
	}

	static fromJson(json: Object): BillSplit {
		return new BillSplit(
			json['id'],
			json['transactionId'],
			json['currency'],
			json['amount'],
			json['BillSplitParticipants'] != null
				? json['BillSplitParticipants']
						.map((i) => BillSplitParticipant.fromJson(i))
						.toList()
				: []
		);
	}

	toJson(): any {
		return {
			id: this.id,
			transactionId: this.transactionId,
			currency: this.currency,
			amount: this.amount,
			BillSplitParticipants: this.BillSplitParticipants.map((i) =>
				i.toJson()
			).toList(),
		};
	}
}

export function calcBillSplit(
	billSplit: BillSplit,
	participant: BillSplitParticipant | null = null,
	changedParticipants: BillSplitParticipant[] = []
) {
	// Just recalc if participant not set
	if (participant == null) {
		const amountLeft = billSplit.amount;

		const amountPerUnchanged =
			amountLeft / billSplit.BillSplitParticipants.length;

		billSplit.BillSplitParticipants.forEach(
			(i) => (i.amount = amountPerUnchanged)
		);
		return;
	}
	// Find the participant in the billSplit object
	const contributor = billSplit.BillSplitParticipants.find(
		(contributor) => contributor.id === participant.id
	);

	// If participant was not found, return
	if (contributor == null) {
		return;
	}

	// Update participant's amount and set the amountChanged flag
	contributor.amount = participant.amount;

	// Update changed participants
	changedParticipants.push(participant);
	const updatedChangedParticipants: BillSplitParticipant[] = [];

	for (const u of changedParticipants) {
		if (updatedChangedParticipants.map((i) => i.id).includes(u.id))
			continue;
		updatedChangedParticipants.push(u);
	}
	changedParticipants = updatedChangedParticipants;

	let totalSet: number = 0;
	// Get the total amount where the amount has been manually set
	changedParticipants.forEach((curr) => (totalSet += curr.amount));
	const amountLeft = billSplit.amount - totalSet;

	const unchangedParticipants = billSplit.BillSplitParticipants.filter(
		(i) => !changedParticipants.map((u) => u.id).includes(i.id)
	);

	// Update unchanged to divide the rest, or set the first participant to pay rest if all already changed
	if (unchangedParticipants.length == 0) {
		billSplit.BillSplitParticipants[0].amount = amountLeft;
	} else {
		const amountPerUnchanged = amountLeft / unchangedParticipants.length;
		unchangedParticipants.forEach((i) => (i.amount = amountPerUnchanged));
	}
}
