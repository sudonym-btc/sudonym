import { TransactionService } from 'module/transaction/transaction.service';
import { firstValueFrom } from 'rxjs';
import { LightningNodeService } from 'service/lightning-node/lightning-node.service';
import { scaffoldGroup } from '../mock/scaffold-group';
import waitForExpect from 'wait-for-expect';
import { PotService } from 'module/pot/pot.service';
import { transaction } from '@sudonym/models/src/mock/bolt11.mock';

scaffoldGroup('Payment', (scaffold) => {
	describe('Bolt11', () => {
		it('should subtract balance from executed payment', async () => {
			scaffold.app.get(TransactionService).create({
				outgoing: true,
				potId: scaffold.entities.pot[0].id,
				type: 'bolt11',
				currencyCode: 'BTC',
				originalAddress: 'lnbc1asdfghj',
				address: 'lnbc1asdfghj',
				amount: 1,
			});
			await Promise.all([
				waitForExpect(() => {
					expect(
						(scaffold.app.get(LightningNodeService) as any).pay.mock
							.calls.length
					).toBe(1);
					expect(
						(scaffold.app.get(LightningNodeService) as any).pay.mock
							.calls[0][0]
					).toBe('lnbc1asdfghj');
				}),
				firstValueFrom(
					scaffold.app.get(PotService).onAfterUpdated
				).then((x) => {
					expect(x.spendableBalance).toBe(
						scaffold.entities.pot[0].spendableBalance - 1
					);
					expect(x.balance).toBe(
						scaffold.entities.pot[0].balance - 1
					);
				}),
			]);
		});
		it('should re-add balance from failed payment', () => {});
	});

	describe('Bolt12', () => {
		it('should subtract balance from executed payment', () => {});
		it('should re-add balance from failed payment', () => {});
	});

	describe('lnurl', () => {
		it('should subtract balance from executed payment', () => {});
		it('should re-add balance from failed payment', () => {});
	});

	describe('lightningAddress', () => {
		it('should subtract balance from executed payment', () => {});
		it('should re-add balance from failed payment', () => {});
	});

	describe('onchain', () => {
		it('should subtract balance from executed payment', async () => {
			scaffold.app.get(TransactionService).create({
				outgoing: true,
				potId: scaffold.entities.pot[0].id,
				type: 'onchain',
				currencyCode: 'BTC',
				originalAddress: 'bc1qwerty',
				address: 'bc1qwerty',
				amount: 1,
			});
			await Promise.all([
				waitForExpect(() => {
					expect(
						(scaffold.app.get(LightningNodeService) as any)
							.withdrawOnChain.mock.calls.length
					).toBe(1);
					expect(
						(scaffold.app.get(LightningNodeService) as any)
							.withdrawOnChain.mock.calls[0]
					).toContain({
						amount: 1,
					});
				}),
				firstValueFrom(
					scaffold.app.get(PotService).onAfterUpdated
				).then((x) => {
					expect(x.spendableBalance).toBe(
						scaffold.entities.pot[0].spendableBalance - 1
					);
					expect(x.balance).toBe(
						scaffold.entities.pot[0].balance - 1
					);
				}),
			]);
		});
		it('should re-add balance from failed payment', () => {});
	});
});
