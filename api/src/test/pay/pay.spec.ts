import { MSATOSHIS, SATOSHIS } from '@sudonym/models';
import { runAsUser } from 'helper/context-request';
import * as lnurl from 'lnurl';
import { PotService } from 'module/pot/pot.service';
import { ReceiverService } from 'module/receiver/receiver.service';
import { SenderService } from 'module/sender/sender.service';
import { TransactionService } from 'module/transaction/transaction.service';
import { firstValueFrom } from 'rxjs';
import { LightningNodeService } from 'service/lightning-node/lightning-node.service';
import * as request from 'supertest';
import waitForExpect from 'wait-for-expect';
import { scaffoldGroup } from '../mock/scaffold-group';

scaffoldGroup('Payment', (scaffold) => {
	describe('Bolt11', () => {
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
				).then((x) =>
					expect(x).toMatchObject({
						spendableBalance:
							scaffold.entities.pot[0].spendableBalance - 1,
						balance: scaffold.entities.pot[0].balance - 1,
					})
				),
			]);
			return await t;
		};
		it('should subtract balance from executed payment', async () => {
			await successfulPayment();
		});
		it('should re-add balance from failed payment', async () => {
			scaffold.app.get(LightningNodeService).waitSendPay = jest.fn(
				async (hash, timeout, part) => {
					await new Promise((resolve) => setTimeout(resolve, 100));
					return {
						id: 23423423,
						payment_preimage: 'mock',
						payment_hash: '543543543543543543534534543543',
						created_at: Date.now().valueOf() / 1000,
						parts: 1,
						partid: 1,
						msatoshi_sent: 1 * MSATOSHIS,
						amount_msat: 1 * MSATOSHIS,
						amount_sent_msat: 1 * MSATOSHIS,
						status: 'failed',
						destination: 'randomnode',
					};
				}
			);

			await successfulPayment();

			// Should re-add balance on failure
			await Promise.all([
				waitForExpect(() =>
					expect(
						(scaffold.app.get(LightningNodeService) as any)
							.waitSendPay.mock.calls.length
					).toBe(1)
				),
				firstValueFrom(
					scaffold.app.get(PotService).onAfterUpdated
				).then((x) =>
					expect(x).toMatchObject({
						spendableBalance:
							scaffold.entities.pot[0].spendableBalance,
						balance: scaffold.entities.pot[0].balance,
					})
				),
			]);
		});

		it('should not get info or pay an expired invoice', async () => {
			// const payreq: PaymentRequest = {};
		});
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
							.withdrawOnChain.mock.calls[0][0]
					).toMatchObject({
						address: 'bc1qwerty',
						satoshis: 1 * SATOSHIS,
					});
				}),
				firstValueFrom(
					scaffold.app.get(PotService).onAfterUpdated
				).then((x) =>
					expect(x).toMatchObject({
						spendableBalance:
							scaffold.entities.pot[0].spendableBalance - 1,
						balance: scaffold.entities.pot[0].balance - 1,
					})
				),
			]);
		});
		it('should re-add balance from failed payment', () => {});
	});

	describe('lnurl withdraw', () => {
		it('should not allow more withdrawals than limitMax', async () => {
			const sender = await scaffold.app.get(SenderService).create({
				type: 'lnurl',
				amountCurrency: 'BTC',
				limitMax: 1,
				potId: scaffold.entities.pot[0].id,
			});
			const data = await request(scaffold.app.getHttpServer()).get(
				lnurl.decode(sender.data).split('/api.mock.sudonym.app').pop()
			);

			const receiver = await runAsUser(scaffold.entities.user[0], () =>
				scaffold.app.get(ReceiverService).create({
					potId: scaffold.entities.pot[0].id,
					type: 'bolt11',
					amount: 0.5,
					amountCurrency: 'BTC',
				})
			);
			const payment = await request(scaffold.app.getHttpServer()).get(
				data.body.callback.split('/api.mock.sudonym.app').pop() +
					'?pr=' +
					receiver.data
			);

			expect(
				await scaffold.app.get(SenderService).amountLeft(sender)
			).toBe(0.5);

			expect(
				(
					await request(scaffold.app.getHttpServer()).get(
						lnurl
							.decode(sender.data)
							.split('/api.mock.sudonym.app')
							.pop()
					)
				).body.maxWithdrawable
			).toBe(0.5 * MSATOSHIS);

			const receiver2 = await runAsUser(scaffold.entities.user[0], () =>
				scaffold.app.get(ReceiverService).create({
					potId: scaffold.entities.pot[0].id,
					type: 'bolt11',
					amount: 0.6,
					amountCurrency: 'BTC',
				})
			);
			const payment2 = await request(scaffold.app.getHttpServer()).get(
				data.body.callback.split('/api.mock.sudonym.app').pop() +
					'?pr=' +
					receiver2.data
			);
			expect(payment2.body.status).toEqual('ERROR');
		});
		it('should re-add balance from failed payment', () => {});
	});
});
