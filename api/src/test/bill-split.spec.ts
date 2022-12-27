import {
	BillSplit,
	BillSplitParticipant,
	calcBillSplit,
} from '@sudonym/models';
import { RecursivePartial } from '@sudonym/models/src/recursive-partial';
import { runAsUser } from 'helper/context-request';
import { BillSplitService } from 'module/bill-split/bill-split.service';
import { TransactionService } from 'module/transaction/transaction.service';
import { scaffoldGroup } from './mock/scaffold-group';

scaffoldGroup('Bill Split', (scaffold) => {
	const successfulPayment = async () => {
		const t = scaffold.app.get(TransactionService).create({
			outgoing: true,
			potId: scaffold.entities.pot[0].id,
			type: 'bolt11',
			currencyCode: 'BTC',
			originalAddress: 'lnbc1asdfghj',
			address: 'lnbc1asdfghj',
			amount: 1,
		});
		return await t;
	};
	it('should create bill split and satisfy payment of participant', async () => {
		// Create a second pot
		await runAsUser(scaffold.entities.user[0], async () => {
			const t = await successfulPayment();
			const billSplit = await scaffold.app.get(BillSplitService).create({
				transactionId: t.entity.id,
				BillSplitParticipants: [{}],
			});
			console.log(billSplit);
			expect(billSplit.entity.BillSplitParticipants.length).toEqual(5);
		});
	});

	it('should adjust bill split payment amounts correctly', async () => {
		const participants: RecursivePartial<BillSplitParticipant>[] = [
			{
				id: 1,
				amount: 2,
			},
			{
				id: 2,
				amount: 2,
			},
			{
				id: 3,
				amount: 2,
			},
			{
				id: 4,
				amount: 2,
			},
			{
				id: 5,
				amount: 2,
			},
		];
		const billSplit: RecursivePartial<BillSplit> = {
			id: 1,
			transactionId: null,
			currency: 'GBP',
			amount: 10,
			BillSplitParticipants: participants,
		};

		calcBillSplit(
			billSplit as any,
			{
				id: 1,
				amount: 4,
			} as any,
			[]
		);

		console.log(billSplit.BillSplitParticipants);

		expect(billSplit.BillSplitParticipants[0].amount).toBe(4);
		expect(billSplit.BillSplitParticipants[1].amount).toBe(1.5);
		expect(billSplit.BillSplitParticipants[2].amount).toBe(1.5);
		expect(billSplit.BillSplitParticipants[3].amount).toBe(1.5);
		expect(billSplit.BillSplitParticipants[4].amount).toBe(1.5);

		billSplit.BillSplitParticipants.shift();
		console.log(billSplit);

		calcBillSplit(billSplit as any, null, []);
		console.log(billSplit);
		expect(billSplit.BillSplitParticipants[0].amount).toBe(2.5);
		expect(billSplit.BillSplitParticipants[1].amount).toBe(2.5);
		expect(billSplit.BillSplitParticipants[2].amount).toBe(2.5);
		expect(billSplit.BillSplitParticipants[3].amount).toBe(2.5);
	});
});
