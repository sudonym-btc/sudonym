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
				potId: scaffold.entities.pot[0].id,
				BillSplitParticipants: [
					{
						amount: 2,
					},
					{
						amount: 2,
					},
					{
						amount: 2,
					},
				],
				amount: 6,
				currency: 'USD',
			});
			expect(billSplit.entity.BillSplitParticipants.length).toEqual(3);
		});
	});

	it('should create bill split and mark first as paid if transaction already paid', async () => {
		// Create a second pot
		await runAsUser(scaffold.entities.user[0], async () => {
			const t = await successfulPayment();
			const billSplit = await scaffold.app.get(BillSplitService).create({
				transactionId: t.entity.id,
				potId: scaffold.entities.pot[0].id,

				BillSplitParticipants: [
					{
						amount: 2,
					},
					{
						amount: 2,
					},
					{
						amount: 2,
					},
				],
				amount: 6,
				currency: 'USD',
			});
			expect(billSplit.entity.BillSplitParticipants[0].paid).toBe(true);
			expect(billSplit.entity.BillSplitParticipants[0].amountPaid).toBe(
				2
			);
		});
	});

	it('should not be able to edit own amount', async () => {
		const participants: RecursivePartial<BillSplitParticipant>[] = [
			{
				id: 1,
				amount: 5,
			},
			{
				id: 2,
				amount: 5,
			},
		];
		const billSplit: RecursivePartial<BillSplit> = {
			id: 1,
			transactionId: 123,
			currency: 'GBP',
			amount: 10,
			BillSplitParticipants: participants,
		};

		expect(() => calcBillSplit(billSplit as any, 0, 4, [])).toThrowError();
	});

	it('should adjust bill split payment amounts correctly for paid tx', async () => {
		const participants: RecursivePartial<BillSplitParticipant>[] = [
			{
				id: 1,
				amount: 0,
			},
			{
				id: 2,
				amount: 0,
			},
			{
				id: 3,
				amount: 0,
			},
		];
		const billSplit: RecursivePartial<BillSplit> = {
			id: 1,
			transactionId: 123,
			currency: 'GBP',
			amount: 6,
			BillSplitParticipants: participants,
		};
		calcBillSplit(billSplit as any);

		expect(billSplit.BillSplitParticipants[0].amount).toBe(2);
		expect(billSplit.BillSplitParticipants[1].amount).toBe(2);
		expect(billSplit.BillSplitParticipants[2].amount).toBe(2);

		calcBillSplit(billSplit as any, 1, 4, []);

		expect(billSplit.BillSplitParticipants[0].amount).toBe(1);
		expect(billSplit.BillSplitParticipants[1].amount).toBe(4);
		expect(billSplit.BillSplitParticipants[2].amount).toBe(1);

		billSplit.BillSplitParticipants.pop();

		calcBillSplit(billSplit as any, null, null, [1]);

		expect(billSplit.BillSplitParticipants[0].amount).toBe(2);
		expect(billSplit.BillSplitParticipants[1].amount).toBe(4);
	});

	it('should adjust bill split payment amounts correctly for unpaid tx', async () => {
		const participants: RecursivePartial<BillSplitParticipant>[] = [
			{
				id: 1,
				amount: 0,
			},
			{
				id: 2,
				amount: 0,
			},
			{
				id: 3,
				amount: 0,
			},
		];
		const billSplit: RecursivePartial<BillSplit> = {
			id: 1,
			transactionId: null,
			currency: 'GBP',
			amount: 6,
			BillSplitParticipants: participants,
		};

		// Calculate inital spread equally
		calcBillSplit(billSplit as any);
		expect(billSplit.BillSplitParticipants[0].amount).toBe(2);
		expect(billSplit.BillSplitParticipants[1].amount).toBe(2);
		expect(billSplit.BillSplitParticipants[2].amount).toBe(2);

		// Change one of the amounts
		calcBillSplit(billSplit as any, 1, 4, []);
		expect(billSplit.BillSplitParticipants[0].amount).toBe(1);
		expect(billSplit.BillSplitParticipants[1].amount).toBe(4);
		expect(billSplit.BillSplitParticipants[2].amount).toBe(1);

		// Change another amount and expect first changed amount to stay the same
		calcBillSplit(billSplit as any, 2, 0, [1]);
		expect(billSplit.BillSplitParticipants[0].amount).toBe(2);
		expect(billSplit.BillSplitParticipants[1].amount).toBe(4);
		expect(billSplit.BillSplitParticipants[2].amount).toBe(0);

		billSplit.BillSplitParticipants.pop();

		calcBillSplit(billSplit as any, null, null, [1]);
		expect(billSplit.BillSplitParticipants[0].amount).toBe(2);
		expect(billSplit.BillSplitParticipants[1].amount).toBe(4);
	});
});
