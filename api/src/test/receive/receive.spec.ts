import { MSATOSHIS, SATOSHIS } from '@sudonym/models';
import { transaction as bolt11Mock } from '@sudonym/models/src/mock/bolt11.mock';
import { PotService } from 'module/pot/pot.service';
import { TransactionService } from 'module/transaction/transaction.service';
import { firstValueFrom } from 'rxjs';
import { BitcoinEvents } from 'service/transaction-listener/bitcoin-events';
import { LightningEvents } from 'service/transaction-listener/lightning-events';
import { scaffoldGroup } from '../mock/scaffold-group';

scaffoldGroup('Receive', (scaffold) => {
	describe('Invoice', () => {
		it('should add balance from succeeded payment', async () => {
			const msatoshi = 500;
			scaffold.app.get(LightningEvents).onEvent.next({
				event: 'invoice',
				data: {
					...bolt11Mock,
					bolt11: scaffold.entities.bolt11Receiver.data,
					status: 'paid',
					msatoshi,
				},
			});
			await Promise.all([
				firstValueFrom(
					scaffold.app.get(TransactionService).onAfterCreated
				).then((x) =>
					expect(x).toMatchObject({
						status: true,
						currencyCode: 'BTC',
						amount: msatoshi / MSATOSHIS,
						potId: scaffold.entities.pot[0].id,
						outgoing: false,
					})
				),
				firstValueFrom(
					scaffold.app.get(PotService).onAfterUpdated
				).then((x) => {
					expect(x.spendableBalance).toBe(
						scaffold.entities.pot[0].spendableBalance +
							msatoshi / MSATOSHIS
					);
					expect(x.balance).toBe(
						scaffold.entities.pot[0].balance + msatoshi / MSATOSHIS
					);
				}),
			]);
		});

		// it('should add unspendable from onchain payment', () => {});

		it('should make spendable after received', async () => {
			const satoshi = 500;
			scaffold.app.get(BitcoinEvents).onTransaction.next({
				outs: [
					{
						fromAddress: 'bc1erwf',
						address: scaffold.entities.onchainReceiver.data,
						value: satoshi,
					},
				],
			});
			await Promise.all([
				firstValueFrom(
					scaffold.app.get(TransactionService).onAfterCreated
				).then((x) => {
					expect(x.status).toBe(true);
					expect(x.currencyCode).toBe('BTC');
					expect(x.amount).toBe(satoshi / SATOSHIS);
					expect(x.potId).toBe(scaffold.entities.pot[0].id);
					expect(x.outgoing).toBe(false);
				}),
				firstValueFrom(
					scaffold.app.get(PotService).onAfterUpdated
				).then((x) => {
					expect(x.spendableBalance).toBe(
						scaffold.entities.pot[0].spendableBalance +
							satoshi / SATOSHIS
					);
					expect(x.balance).toBe(
						scaffold.entities.pot[0].balance + satoshi / SATOSHIS
					);
				}),
			]);
		});
	});
});

// {"version":2,"locktime":0,"ins":[{"hash":{"type":"Buffer","data":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]},"index":4294967295,"script":{"type":"Buffer","data":[1,17,1,1]},"sequence":4294967295,"witness":[{"type":"Buffer","data":[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}]}],"outs":[{"value":5000000000,"script":{"type":"Buffer","data":[0,20,153,32,202,173,112,151,5,170,82,208,205,152,208,180,121,65,241,183,194,151]}},{"value":0,"script":{"type":"Buffer","data":[106,36,170,33,169,237,226,246,28,63,113,209,222,253,63,169,153,223,163,105,83,117,92,105,6,137,121,153,98,180,139,235,216,54,151,78,140,249]}}]}
