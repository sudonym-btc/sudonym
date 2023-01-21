import {
	BillSplit,
	BillSplitParticipant,
	calcBillSplit,
	MSATOSHIS,
} from '@sudonym/models';
import { RecursivePartial } from '@sudonym/models/src/recursive-partial';
import { runAsUser } from 'helper/context-request';
import { BillSplitParticipantService } from 'module/bill-split-participant/bill-split-participant.service';
import { BillSplitService } from 'module/bill-split/bill-split.service';
import { ReceiverService } from 'module/receiver/receiver.service';
import { TransactionService } from 'module/transaction/transaction.service';
import { bolt11Encode } from './mock/classes';
import { scaffoldGroup } from './mock/scaffold-group';
import { scaffoldTest } from './mock/scaffold-test';

scaffoldGroup('Bill Split', (scaffold) => {
	const successfulPayment = async (entities) => {
		const t = scaffold.app.get(TransactionService).create({
			outgoing: true,
			potId: entities.pot[0].id,
			type: 'bolt11',
			currencyCode: 'BTC',
			originalAddress: bolt11Encode(1 * MSATOSHIS).paymentRequest,
			address: bolt11Encode(1 * MSATOSHIS).paymentRequest,
			amount: 1,
		});
		return await t;
	};
	scaffoldTest(
		scaffold,
		'should create bill split and satisfy payment of participant',
		async (entities) => {
			// Create a second pot
			await runAsUser(entities.user[0], async () => {
				const t = await successfulPayment(entities);
				const billSplit = await scaffold.app
					.get(BillSplitService)
					.create({
						transactionId: t.entity.id,
						potId: entities.pot[0].id,
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
				expect(billSplit.entity.BillSplitParticipants.length).toEqual(
					3
				);
			});
		}
	);

	scaffoldTest(
		scaffold,
		'should create bill split and mark first as paid if transaction already paid',
		async (entities) => {
			// Create a second pot
			await runAsUser(entities.user[0], async () => {
				const t = await successfulPayment(entities);
				const billSplit = await scaffold.app
					.get(BillSplitService)
					.create({
						transactionId: t.entity.id,
						potId: entities.pot[0].id,

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
				expect(billSplit.entity.BillSplitParticipants[0].paid).toBe(
					true
				);
				expect(
					billSplit.entity.BillSplitParticipants[0].amountPaid
				).toBe(2);
			});
		}
	);

	scaffoldTest(
		scaffold,
		'should not be able to edit own amount',
		async () => {
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

			expect(() =>
				calcBillSplit(billSplit as any, 0, 4, [])
			).toThrowError();
		}
	);

	scaffoldTest(
		scaffold,
		'should mark participant as paid for amounts nearing full amount',
		async (entities) => {
			const participants: RecursivePartial<BillSplitParticipant>[] = [
				{
					amount: 1,
				},
				{
					amount: 1,
				},
			];
			const { entity: billSplit } = await scaffold.app
				.get(BillSplitService)
				.create({
					currency: 'GBP',
					amount: 2,
					potId: entities.pot[0].id,
					BillSplitParticipants: participants,
				});
			const { entity: receiver } = await scaffold.app
				.get(ReceiverService)
				.create({
					potId: entities.pot[0].id,
					billSplitParticipantId:
						billSplit.BillSplitParticipants[1].id,
					type: 'lnurl',
					amount: 1,
					amountCurrency: 'BTC',
				});

			const { entity: transaction } = await scaffold.app
				.get(TransactionService)
				.create({
					type: 'lnurl',
					address: bolt11Encode(1 * MSATOSHIS).paymentRequest,
					outgoing: false,
					receiverId: receiver.id,
					potId: entities.pot[0].id,
					amount: 0.9998,
					currencyCode: 'GBP',
					status: true,
				});

			const billSplitParticipant = await scaffold.app
				.get(BillSplitParticipantService)
				.findOne(billSplit.BillSplitParticipants[1].id);

			expect(billSplitParticipant.amount).toBe(1);
			expect(billSplitParticipant.amountPaid).toBe(transaction.amount);
			expect(billSplitParticipant.paid).toBe(true);
		}
	);

	scaffoldTest(
		scaffold,
		'should not allow incorrect bill split amounts',
		async (entities) => {
			const participants: RecursivePartial<BillSplitParticipant>[] = [
				{
					amount: 1,
				},
				{
					amount: 2,
				},
			];

			expect(
				scaffold.app.get(BillSplitService).create({
					currency: 'GBP',
					amount: 2,
					potId: entities.pot[0].id,
					BillSplitParticipants: participants,
				})
			).rejects.toThrowError();
		}
	);

	scaffoldTest(
		scaffold,
		'should not allow zero amounts',
		async (entities) => {
			const participants: RecursivePartial<BillSplitParticipant>[] = [
				{
					amount: 2,
				},
				{
					amount: 0,
				},
			];

			expect(
				scaffold.app.get(BillSplitService).create({
					currency: 'GBP',
					amount: 2,
					potId: entities.pot[0].id,
					BillSplitParticipants: participants,
				})
			).rejects.toThrowError();
		}
	);

	scaffoldTest(
		scaffold,
		'should adjust bill split payment amounts correctly for paid tx',
		async () => {
			const participants: RecursivePartial<BillSplitParticipant>[] = [
				{
					amount: 0,
				},
				{
					amount: 0,
				},
				{
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
		}
	);

	scaffoldTest(
		scaffold,
		'should adjust bill split payment amounts correctly for unpaid tx',
		async () => {
			const participants: RecursivePartial<BillSplitParticipant>[] = [
				{
					amount: 0,
				},
				{
					amount: 0,
				},
				{
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
		}
	);
});
