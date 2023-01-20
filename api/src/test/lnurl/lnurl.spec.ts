import {
	ActionRemoteResponse,
	LNURLProtocolError,
	LnurlStatusResponse,
	MSATOSHIS,
	Payment,
	PaymentRequest,
	PaymentRequestCallback,
	Transaction,
	Withdraw,
	WithdrawRequest,
} from '@sudonym/models';
import axios from 'axios';
import * as bolt11 from 'bolt11';
import { ActionService } from 'module/action/action.service';
import { LightningAddressController } from 'module/lightning/lnurl/lightning-address/lightning-address.controller';
import { LnUrlHandlerService } from 'module/lightning/lnurl/lnurl-handler/lnurl-handler.service';
import { ReceiverService } from 'module/receiver/receiver.service';
import { SenderService } from 'module/sender/sender.service';
import { firstValueFrom } from 'rxjs';
import { LightningNodeService } from 'service/lightning-node/lightning-node.service';
import { bolt11Encode } from 'test/mock/classes';
import { scaffoldTest } from 'test/mock/scaffold-test';
import waitForExpect from 'wait-for-expect';
import { scaffoldGroup } from '../mock/scaffold-group';
jest.mock('axios');

scaffoldGroup('LnUrl', (scaffold) => {
	describe('Incoming Requests', () => {
		describe('Withdraw', () => {
			describe('serve', () => {
				scaffoldTest(
					scaffold,
					'should limit based on max payment',
					async (entities) => {
						const { entity: sender } = await scaffold.app
							.get(SenderService)
							.create({
								potId: entities.pot[0].id,
								type: 'lnurl',
								limitMax: 1,
								limitMin: 0.2,
								amountCurrency: 'BTC',
							});

						const tag = (await scaffold.app
							.get(LnUrlHandlerService)
							.serve(sender.lnurlId)) as WithdrawRequest;

						expect(tag.minWithdrawable).toBe(
							sender.limitMin * MSATOSHIS
						);
						expect(tag.maxWithdrawable).toBe(
							sender.limitMax * MSATOSHIS
						);
					}
				);
			});
			describe('execute', () => {
				scaffoldTest(
					scaffold,
					'should pay the correct amount',
					async (entities) => {
						const { entity: sender } = await scaffold.app
							.get(SenderService)
							.create({
								potId: entities.pot[0].id,
								type: 'lnurl',
								limitMax: 1,
								limitMin: 0.2,
								amountCurrency: 'BTC',
							});

						const response = await scaffold.app
							.get(LnUrlHandlerService)
							.handle<LnurlStatusResponse>(sender.lnurlId, {
								k1: '123',
								pr: (
									await scaffold.app
										.get(LightningNodeService)
										.createInvoice(
											sender.limitMax * MSATOSHIS
										)
								).bolt11,
							});
						expect(response.status).toBe('OK');
					}
				);
			});
			describe('error', () => {
				scaffoldTest(
					scaffold,
					'should not pay an incorrect amount',
					async (entities) => {
						const { entity: sender } = await scaffold.app
							.get(SenderService)
							.create({
								potId: entities.pot[0].id,
								type: 'lnurl',
								limitMax: 1,
								limitMin: 0.2,
								amountCurrency: 'BTC',
							});

						const response = await scaffold.app
							.get(LnUrlHandlerService)
							.handle<LnurlStatusResponse>(sender.lnurlId, {
								k1: '123',
								pr: (
									await scaffold.app
										.get(LightningNodeService)
										.createInvoice(
											sender.limitMax * MSATOSHIS + 1
										)
								).bolt11,
							});

						expect(response.status).toBe('ERROR');
						expect(response.reason).toContain('available');
					}
				);
			});
		});
		describe('Pay', () => {
			describe('lightningAddress', () => {
				scaffoldTest(
					scaffold,
					'should serve info endpoint',
					async (entities) => {
						const p = (await scaffold.app
							.get(LightningAddressController)
							.lightningAddress(
								entities.user[0].lightningAddress
							)) as PaymentRequest;

						expect(p.minSendable).toBe(1000);
						expect(p.tag).toBe('payRequest');
					}
				);
			});
			describe('serve', () => {
				scaffoldTest(
					scaffold,
					'should serve info endpoint',
					async (entities) => {
						const { entity: receiver } = await scaffold.app
							.get(ReceiverService)
							.create({
								potId: entities.pot[0].id,
								type: 'lnurl',
								amountCurrency: 'BTC',
								amount: 1,
							});

						const tag = (await scaffold.app
							.get(LnUrlHandlerService)
							.serve(receiver.lnurlId)) as PaymentRequest;
						expect(tag.minSendable).toBe(
							receiver.amount * MSATOSHIS
						);
					}
				);
			});
			describe('execute', () => {
				scaffoldTest(
					scaffold,
					'should serve callback endpoint with correct bolt11',
					async (entities) => {
						const { entity: receiver } = await scaffold.app
							.get(ReceiverService)
							.create({
								potId: entities.pot[0].id,
								type: 'lnurl',
								amountCurrency: 'BTC',
								amount: 1,
							});

						const tag = await scaffold.app
							.get(LnUrlHandlerService)
							.handle<PaymentRequestCallback>(receiver.lnurlId, {
								amount: 1000,
							});
						// todo: mock description hash

						expect(bolt11.decode(tag.pr).millisatoshis).toBe(
							'1000'
						);
					}
				);
			});
			describe('error', () => {});
		});
	});
	describe('Outgoing Request', () => {
		describe('Withdraw', () => {
			describe('parse', () => {
				scaffoldTest(
					scaffold,
					'should parse withdraw url',
					async (entities) => {
						jest.spyOn(axios, 'get').mockResolvedValueOnce({
							status: 200,
							data: {
								tag: 'withdrawRequest', // type of LNURL
								callback: 'http://tandomurl.com', // The URL which LN SERVICE would accept a withdrawal Lightning invoice as query parameter
								k1: '1234', // Random or non-random string to identify the user's LN WALLET when using the callback URL
								defaultDescription: 'hi', // A default withdrawal invoice description
								minWithdrawable: 1000, // Min amount (in millisatoshis) the user can withdraw from LN SERVICE, or 0
								maxWithdrawable: 1000, // Max amount (in millisatoshis) the user can withdraw from LN SERVICE, or equal to minWithdrawable if the user has no choice over the amounts
							},
						});
						const url = 'lnurlw://coincorner.com/lnurlw';
						const info = await scaffold.app
							.get(ActionService)
							.parse(url);
						expect(info.withdraw).toBeTruthy();
						expect(info.withdraw.minAmount).toBe(1000 / MSATOSHIS);
					}
				);
			});
			describe('execute', () => {
				scaffoldTest(
					scaffold,
					'should withdraw to pot',
					async (entities) => {
						const getter = jest.spyOn(axios, 'get');
						const tag = {
							tag: 'withdrawRequest', // type of LNURL
							callback: 'https://tandomurl.com', // The URL which LN SERVICE would accept a withdrawal Lightning invoice as query parameter
							k1: 123, // Random or non-random string to identify the user's LN WALLET when using the callback URL
							defaultDescription: 'hi', // A default withdrawal invoice description
							minWithdrawable: 1000, // Min amount (in millisatoshis) the user can withdraw from LN SERVICE, or 0
							maxWithdrawable: 1000, // Max amount (in millisatoshis) the user can withdraw from LN SERVICE, or equal to minWithdrawable if the user has no choice over the amounts
						};
						getter.mockResolvedValueOnce({
							status: 200,
							data: { status: 'OK' },
						});
						scaffold.app.get(ActionService).execute(
							Withdraw.fromJson({
								amount: 0.1,
								potId: entities.pot[0].id,
								remoteResponses: [
									{
										success: true,
										data: tag,
									},
								],
							})
						);
						const { entity: receiver } = await firstValueFrom(
							scaffold.app.get(ReceiverService).afterCreate
						);
						expect(await receiver.potId).toBe(entities.pot[0].id);

						await waitForExpect(() => {
							const call =
								getter.mock.calls[getter.mock.calls.length - 1];
							const url = new URL(call[0]);
							// Check that has called the remote service to trigger withdraw
							expect(tag.callback).toContain(url.host);
							expect(url.searchParams.get('k1')).toBe(
								tag.k1.toString()
							);
							expect(url.searchParams.get('pr')).toBe(
								receiver.data
							);
						});
					}
				);
			});
			describe('error', () => {
				scaffoldTest(
					scaffold,
					'should respond with error from remote',
					async (entities) => {
						const getter = jest.spyOn(axios, 'get');
						const tag = {
							tag: 'withdrawRequest', // type of LNURL
							callback: 'https://tandomurl.com', // The URL which LN SERVICE would accept a withdrawal Lightning invoice as query parameter
							k1: 123, // Random or non-random string to identify the user's LN WALLET when using the callback URL
							defaultDescription: 'hi', // A default withdrawal invoice description
							minWithdrawable: 1000, // Min amount (in millisatoshis) the user can withdraw from LN SERVICE, or 0
							maxWithdrawable: 1000, // Max amount (in millisatoshis) the user can withdraw from LN SERVICE, or equal to minWithdrawable if the user has no choice over the amounts
						};
						getter.mockRejectedValueOnce({
							status: 500,
							data: {
								status: 'ERROR',
								reason: 'This is the reason',
							},
						});

						try {
							await scaffold.app.get(ActionService).execute(
								Withdraw.fromJson({
									amount: 0.1,
									potId: entities.pot[0].id,
									remoteResponses: [
										{
											success: true,
											data: tag,
										},
									],
								})
							);
							throw new Error();
						} catch (e) {
							expect(e instanceof ActionRemoteResponse).toBe(
								true
							);
							expect(e.data instanceof LNURLProtocolError).toBe(
								true
							);
							expect(e.data.message).toBe('This is the reason');
						}

						await waitForExpect(() => {
							const call =
								getter.mock.calls[getter.mock.calls.length - 1];
							const url = new URL(call[0]);
							// Check that has called the remote service to trigger withdraw
							expect(tag.callback).toContain(url.host);
							expect(url.searchParams.get('k1')).toBe(
								tag.k1.toString()
							);
						});
					}
				);
			});
		});
		describe('Pay', () => {
			const tag = {
				tag: 'payRequest', // type of LNURL
				callback: 'https://randomurl.com', // The URL which LN SERVICE would accept a withdrawal Lightning invoice as query parameter
				minSendable: 1000, // Min amount (in millisatoshis) the user can withdraw from LN SERVICE, or 0
				maxSendable: 1000, // Max amount (in millisatoshis) the user can withdraw from LN SERVICE, or equal to minWithdrawable if the user has no choice over the amounts
			};
			const responseTag = {
				pr: bolt11Encode(0.1 * MSATOSHIS).paymentRequest,
			} as PaymentRequestCallback;
			describe('parse', () => {
				scaffoldTest(
					scaffold,
					'should parse and return payment object',
					async (entities) => {
						jest.spyOn(axios, 'get').mockResolvedValueOnce({
							status: 200,
							data: tag,
						});
						const response = await scaffold.app
							.get(ActionService)
							.parse('test@domain.com');
						expect(response.payment).toBeTruthy();
						expect(response.payment.maxAmount).toBe(
							1000 / MSATOSHIS
						);
						expect(response.payment.minAmount).toBe(
							1000 / MSATOSHIS
						);
						expect(response.payment.amount).toBe(1000 / MSATOSHIS);
					}
				);
			});
			describe('info', () => {
				scaffoldTest(
					scaffold,
					'should get fee info and return payment object',
					async (entities) => {
						jest.spyOn(axios, 'get').mockResolvedValueOnce({
							status: 200,
							data: responseTag,
						});
						const response = await scaffold.app
							.get(ActionService)
							.info<Payment>(
								Payment.fromJson({
									originalAddress: 'test@coincorner.com',
									amount: 0.1,
									potId: entities.pot[0].id,
									remoteResponses: [
										{
											success: true,
											data: tag,
										},
									],
								})
							);
						expect(response).toBeTruthy();
						expect(response.fee).toBeTruthy();
						expect(response.feeCurrency).toBe('BTC');
						expect(response.amount).toBe(0.1);
					}
				);
			});
			describe('execute', () => {
				scaffoldTest(
					scaffold,
					'should trigger payment of pr',
					async (entities) => {
						jest.spyOn(axios, 'get').mockResolvedValueOnce({
							status: 200,
							data: responseTag,
						});
						const response = await scaffold.app
							.get(ActionService)
							.execute<Transaction>(
								Payment.fromJson({
									originalAddress: 'test@coincorner.com',
									amount: 0.1,
									potId: entities.pot[0].id,
									remoteResponses: [
										{
											success: true,
											data: tag,
										},
										{
											success: true,
											data: responseTag,
										},
									],
								})
							);
						expect(response.amount).toBe(0.1);
						expect(response.currencyCode).toBe('BTC');
					}
				);
			});
			describe('error', () => {
				scaffoldTest(
					scaffold,
					'should not trigger payment of pr if amounts differ',
					async (entities) => {
						// jest.spyOn(axios, 'get').mockResolvedValueOnce({
						// 	status: 200,
						// 	data: tag,
						// });
						jest.spyOn(axios, 'get').mockResolvedValue({
							status: 200,
							data: {
								...responseTag,
								pr: bolt11Encode(1 * MSATOSHIS).paymentRequest,
							},
						});
						try {
							await scaffold.app
								.get(ActionService)
								.execute<Transaction>(
									Payment.fromJson({
										originalAddress: 'test@coincorner.com',
										amount: 0.1,
										potId: entities.pot[0].id,
										remoteResponses: [
											{
												success: true,
												data: tag,
											},
											{
												success: true,
												data: responseTag,
											},
										],
									})
								);
							throw Error();
						} catch (e) {
							expect(e).toBeInstanceOf(LNURLProtocolError);
							expect(e.message).toContain('higher amount');
						}
					}
				);

				scaffoldTest(
					scaffold,
					'should return correct reponse on LNURL spec error with HTTP error code',
					async (entities) => {
						jest.spyOn(axios, 'get').mockRejectedValueOnce({
							data: {
								status: 'ERROR',
								reason: 'LNURL ERROR',
							},
						});
						try {
							await scaffold.app
								.get(ActionService)
								.parse('test@domain.com');
							throw new Error();
						} catch (e) {
							expect(e).toBeInstanceOf(LNURLProtocolError);
							expect(e.message).toBe('LNURL ERROR');
						}
					}
				);
				scaffoldTest(
					scaffold,
					'should return correct reponse on LNURL spec error without HTTP error code',
					async (entities) => {
						jest.spyOn(axios, 'get').mockResolvedValueOnce({
							data: {
								status: 'ERROR',
								reason: 'LNURL ERROR',
							},
						});

						try {
							await scaffold.app
								.get(ActionService)
								.parse('test@domain.com');
							throw new Error();
						} catch (e) {
							expect(e).toBeInstanceOf(LNURLProtocolError);
							expect(e.message).toBe('LNURL ERROR');
						}
					}
				);
			});
		});
	});
});
