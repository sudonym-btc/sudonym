import { MSATOSHIS, SATOSHIS } from '@sudonym/models';
import { runAsUser } from 'helper/context-request';
import * as lnurl from 'lnurl';
import { PotService } from 'module/pot/pot.service';
import { ReceiverService } from 'module/receiver/receiver.service';
import { SenderService } from 'module/sender/sender.service';
import { TransactionService } from 'module/transaction/transaction.service';
import { filter, firstValueFrom } from 'rxjs';
import {
	LightningError,
	LightningNodeService,
} from 'service/lightning-node/lightning-node.service';
import * as request from 'supertest';
import { bolt11Encode, MockLightningNodeService } from 'test/mock/classes';
import { mockEntities } from 'test/mock/create-mock-entities';
import { scaffoldTest } from 'test/mock/scaffold-test';
import waitForExpect from 'wait-for-expect';
import { scaffoldGroup } from '../mock/scaffold-group';

scaffoldGroup('Payment', (scaffold) => {
	describe('Bolt11', () => {
		const attempt = async (
			entities: mockEntities,
			mockPay: jest.Mock | jest.SpyInstance
		) => {
			const addr = bolt11Encode(1 * MSATOSHIS).paymentRequest;

			const waitExpects = Promise.all([
				waitForExpect(() => {
					expect(mockPay.mock.calls.length).toBe(1);
					expect(mockPay.mock.calls[0][0]).toBe(addr);
				}),
				firstValueFrom(
					scaffold.app
						.get(PotService)
						.onAfterUpdated.pipe(
							filter((x) => x.id == entities.pot[0].id)
						)
				).then((x) =>
					expect(x).toMatchObject({
						spendableBalance: entities.pot[0].spendableBalance - 1,
						balance: entities.pot[0].balance - 1,
					})
				),
			]);
			const t = scaffold.app.get(TransactionService).create({
				outgoing: true,
				potId: entities.pot[0].id,
				type: 'bolt11',
				currencyCode: 'BTC',
				originalAddress: addr,
				address: addr,
				amount: 1,
			});
			await waitExpects;
			return t;
		};
		scaffoldTest(
			scaffold,
			'should subtract balance from executed payment',
			async (entities) => {
				const mockPay = jest
					.spyOn(scaffold.app.get(LightningNodeService), 'pay')
					.mockImplementationOnce(
						(
							scaffold.app.get(
								LightningNodeService
							) as MockLightningNodeService
						).mockPay({
							status: 'failed',
						})
					);
				await attempt(entities, mockPay);
			}
		);
		// 	scaffoldTest(
		// 		scaffold,
		// 		'should re-add balance from failed payment bolt11',
		// 		async (entities) => {
		// 			jest.spyOn(
		// 				scaffold.app.get(LightningNodeService),
		// 				'waitSendPay'
		// 			).mockImplementationOnce(
		// 				(
		// 					scaffold.app.get(
		// 						LightningNodeService
		// 					) as MockLightningNodeService
		// 				).mockSendPay({
		// 					status: 'failed',
		// 				})
		// 			);
		// 			const mockPay = jest
		// 				.spyOn(scaffold.app.get(LightningNodeService), 'pay')
		// 				.mockImplementationOnce(
		// 					(
		// 						scaffold.app.get(
		// 							LightningNodeService
		// 						) as MockLightningNodeService
		// 					).mockPay({
		// 						status: 'failed',
		// 					})
		// 				);
		// 			jest.spyOn(
		// 				scaffold.app.get(LightningNodeService),
		// 				'listPays'
		// 			).mockImplementationOnce(
		// 				(
		// 					scaffold.app.get(
		// 						LightningNodeService
		// 					) as MockLightningNodeService
		// 				).mockListPays({
		// 					status: 'failed',
		// 				})
		// 			);

		// 			await attempt(entities, mockPay);

		// 			// Should re-add balance on failure
		// 			await Promise.all([
		// 				firstValueFrom(
		// 					scaffold.app
		// 						.get(PotService)
		// 						.onAfterUpdated.pipe(
		// 							filter((x) => x.id == entities.pot[0].id)
		// 						)
		// 				).then((x) => {
		// 					expect(x).toMatchObject({
		// 						spendableBalance: entities.pot[0].spendableBalance,
		// 						balance: entities.pot[0].balance,
		// 					});
		// 				}),
		// 			]);
		// 		}
		// 	);

		scaffoldTest(
			scaffold,
			'should fail when waitsendpay returns forgotten error type',
			async (entities) => {
				const e = {
					type: 'lightning',
					name: 'LightningError',
					message: 'Payment failure reason unknown',
					code: 209,
					fullType: 'lightning',
				};
				const mockedWaitsendpay = jest
					.spyOn(
						scaffold.app.get(LightningNodeService),
						'waitSendPay'
					)
					.mockImplementationOnce(async (hash, timeout, part) => {
						await new Promise((resolve) =>
							setTimeout(resolve, 100)
						);
						throw new LightningError(e, e.message, 500, e);
					});

				const mockPay = jest
					.spyOn(scaffold.app.get(LightningNodeService), 'pay')
					.mockImplementationOnce(
						(
							scaffold.app.get(
								LightningNodeService
							) as MockLightningNodeService
						).mockPay({})
					);

				jest.spyOn(scaffold.app.get(LightningNodeService), 'listPays')
					.mockImplementationOnce(
						(
							scaffold.app.get(
								LightningNodeService
							) as MockLightningNodeService
						).mockListPays({
							status: 'pending',
						})
					)
					.mockImplementationOnce(
						(
							scaffold.app.get(
								LightningNodeService
							) as MockLightningNodeService
						).mockListPays({
							status: 'failed',
						})
					);

				const { entity: transaction } = await attempt(
					entities,
					mockPay
				);

				// Should re-add balance on failure
				await Promise.all([
					// waitForExpect(() => {
					// 	console.log(mockedWaitsendpay.mock.calls.length);
					// 	expect(mockedWaitsendpay.mock.calls.length).toBe(1);
					// }),
					firstValueFrom(
						scaffold.app
							.get(PotService)
							.onAfterUpdated.pipe(
								filter((x) => x.id == entities.pot[0].id)
							)
					).then((x) =>
						expect(x).toMatchObject({
							spendableBalance: entities.pot[0].spendableBalance,
							balance: entities.pot[0].balance,
						})
					),
					firstValueFrom(
						scaffold.app
							.get(TransactionService)
							.onAfterUpdated.pipe(
								filter(
									(x) =>
										x.status == false &&
										x.id == transaction.id
								)
							)
					).then((x) =>
						expect(x).toMatchObject({
							status: false,
							// errorMessage: e.message,
						})
					),
				]);
			}
		);

		scaffoldTest(
			scaffold,
			'should fail and add balance to a deleted pot',
			async (entities) => {
				const mockPay = jest
					.spyOn(scaffold.app.get(LightningNodeService), 'pay')
					.mockImplementationOnce(
						(
							scaffold.app.get(
								LightningNodeService
							) as MockLightningNodeService
						).mockPay({
							status: 'failed',
						})
					);
				jest.spyOn(
					scaffold.app.get(LightningNodeService),
					'listPays'
				).mockImplementationOnce(
					(
						scaffold.app.get(
							LightningNodeService
						) as MockLightningNodeService
					).mockListPays({
						status: 'failed',
					})
				);

				const { entity: transaction } = await attempt(
					entities,
					mockPay
				);

				const potUpdated = firstValueFrom(
					scaffold.app
						.get(PotService)
						.onAfterUpdated.pipe(
							filter((x) => x.id == entities.pot[0].id)
						)
				).then((x) =>
					expect(x).toMatchObject({
						id: entities.pot[0].id,
						spendableBalance: entities.pot[0].spendableBalance,
						balance: entities.pot[0].balance,
					})
				);

				const transactionUpdated = firstValueFrom(
					scaffold.app
						.get(TransactionService)
						.onAfterUpdated.pipe(
							filter(
								(x) =>
									x.status == false && x.id == transaction.id
							)
						)
				).then((x) =>
					expect(x).toMatchObject({
						status: false,
					})
				);

				await runAsUser(entities.user[0], () =>
					scaffold.app.get(PotService).create({
						name: 'test2',
					})
				);

				await scaffold.app.get(PotService).delete(entities.pot[0].id);
				// Should re-add balance on failure
				await Promise.all([potUpdated, transactionUpdated]);
			}
		);

		// 	// scaffoldTest(
		// 	// 	scaffold,
		// 	// 	'should not get info or pay an expired invoice',
		// 	// 	async () => {
		// 	// 		// const payreq: PaymentRequest = {};
		// 	// 	}
		// 	// );
	});

	describe('Bolt12', () => {
		// scaffoldTest(
		// 	scaffold,
		// 	'should subtract balance from executed payment',
		// 	() => {}
		// );
		// scaffoldTest(
		// 	scaffold,
		// 	'should re-add balance from failed payment',
		// 	() => {}
		// );
	});

	describe('lnurl', () => {
		// scaffoldTest(
		// 	scaffold,
		// 	'should subtract balance from executed payment',
		// 	() => {}
		// );
		// scaffoldTest(
		// 	scaffold,
		// 	'should re-add balance from failed payment',
		// 	() => {}
		// );
	});

	describe('lightningAddress', () => {
		// scaffoldTest(
		// 	scaffold,
		// 	'should subtract balance from executed payment',
		// 	() => {}
		// );
		// scaffoldTest(
		// 	scaffold,
		// 	'should re-add balance from failed payment',
		// 	() => {}
		// );
	});

	describe('onchain', () => {
		scaffoldTest(
			scaffold,
			'should subtract balance from executed payment',
			async (entities) => {
				const addr = bolt11Encode(1 * MSATOSHIS).paymentRequest;
				const mockedWithdraw = jest.spyOn(
					scaffold.app.get(LightningNodeService),
					'withdrawOnChain'
				);
				scaffold.app.get(TransactionService).create({
					outgoing: true,
					potId: entities.pot[0].id,
					type: 'onchain',
					currencyCode: 'BTC',
					originalAddress: 'bc1qwerty',
					address: 'bc1qwerty',
					amount: 1,
				});
				await Promise.all([
					waitForExpect(() => {
						expect(mockedWithdraw.mock.calls.length).toBe(1);
						expect(mockedWithdraw.mock.calls[0][0]).toMatchObject({
							address: 'bc1qwerty',
							satoshis: 1 * SATOSHIS,
						});
					}),
					firstValueFrom(
						scaffold.app
							.get(PotService)
							.onAfterUpdated.pipe(
								filter((x) => x.id == entities.pot[0].id)
							)
					).then((x) =>
						expect(x).toMatchObject({
							spendableBalance:
								entities.pot[0].spendableBalance - 1,
							balance: entities.pot[0].balance - 1,
						})
					),
				]);
			}
		);
		// scaffoldTest(
		// 	scaffold,
		// 	'should re-add balance from failed payment',
		// 	() => {}
		// );
	});

	describe('lnurl withdraw', () => {
		scaffoldTest(
			scaffold,
			'should not allow more withdrawals than limitMax',
			async (entities) => {
				const { entity: sender } = await scaffold.app
					.get(SenderService)
					.create({
						type: 'lnurl',
						amountCurrency: 'BTC',
						limitMax: 1,
						potId: entities.pot[0].id,
					});
				const data = await request(scaffold.app.getHttpServer()).get(
					lnurl
						.decode(sender.data)
						.split('/api.mock.sudonym.app')
						.pop()
				);

				const { entity: receiver } = await runAsUser(
					entities.user[0],
					() =>
						scaffold.app.get(ReceiverService).create({
							potId: entities.pot[0].id,
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

				const { entity: receiver2 } = await runAsUser(
					entities.user[0],
					() =>
						scaffold.app.get(ReceiverService).create({
							potId: entities.pot[0].id,
							type: 'bolt11',
							amount: 0.6,
							amountCurrency: 'BTC',
						})
				);
				const payment2 = await request(
					scaffold.app.getHttpServer()
				).get(
					data.body.callback.split('/api.mock.sudonym.app').pop() +
						'?pr=' +
						receiver2.data
				);
				expect(payment2.body.status).toEqual('ERROR');
			}
		);
		// scaffoldTest(
		// 	scaffold,
		// 	'should re-add balance from failed payment',
		// 	() => {}
		// );
	});
});
