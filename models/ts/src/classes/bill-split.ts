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
	participant: BillSplitParticipant | null,
	changedParticipants: BillSplitParticipant[] = []
) {
	// Just recalc if participant not set
	if (!participant || participant == null) {
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
	if (!contributor) {
		return;
	}

	// Update participant's amount and set the amountChanged flag
	contributor.amount = participant.amount;

	// Update changed participants
	changedParticipants.push(participant);
	changedParticipants = changedParticipants.reduce((acc, curr) => {
		if (acc.map((i) => i.id).includes(curr.id)) return acc;
		acc.push(curr);
		return acc;
	}, []);

	// Get the total amount where the amount has been manually set
	const totalSet = changedParticipants
		.map((i) => i.amount)
		.reduce((acc, curr) => acc + curr, 0);
	const amountLeft = billSplit.amount - totalSet;

	const unchangedParticipants = billSplit.BillSplitParticipants.filter(
		(i) => !changedParticipants.map((u) => u.id).includes(i.id)
	);

	console.log(amountLeft);
	console.log(unchangedParticipants);

	// Update unchanged to divide the rest, or set the first participant to pay rest if all already changed
	if (!unchangedParticipants.length) {
		billSplit.BillSplitParticipants[0].amount = amountLeft;
	} else {
		const amountPerUnchanged = amountLeft / unchangedParticipants.length;
		unchangedParticipants.forEach((i) => (i.amount = amountPerUnchanged));
	}
}
