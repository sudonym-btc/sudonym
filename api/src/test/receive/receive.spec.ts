import { scaffoldGroup } from '../mock/scaffold-group';
import { LightningEvents } from 'service/transaction-listener/lightning-events';
import { TransactionService } from 'module/transaction/transaction.service';
import { transaction as bolt11Mock } from '@sudonym/models/src/mock/bolt11.mock';
import { transaction as onchainMock } from '@sudonym/models/src/mock/onchain.mock';
import { firstValueFrom } from 'rxjs';
import { ReceiverService } from 'module/receiver/receiver.service';
import { MSATOSHIS, SATOSHIS } from '@sudonym/models';
import { PotService } from 'module/pot/pot.service';
import { BitcoinEvents } from 'service/transaction-listener/bitcoin-events';

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
				).then((x) => {
					expect(x.status).toBe(true);
					expect(x.currencyCode).toBe('BTC');
					expect(x.amount).toBe(msatoshi / MSATOSHIS);
					expect(x.potId).toBe(scaffold.entities.pot[0].id);
					expect(x.outgoing).toBe(false);
				}),
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
	});

	describe('Onchain', () => {
		it('should add unspendable from onchain payment', () => {});

		it('should make spendable after onchain confirmation', async () => {
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

		it('should make spendable after onchain confirmation', () => {});
	});
});
