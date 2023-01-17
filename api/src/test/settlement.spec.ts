import { MSATOSHIS } from '@sudonym/models';
import * as bolt11 from 'bolt11';
import { Config } from 'config/config';
import { runAsUser } from 'helper/context-request';
import { PotService } from 'module/pot/pot.service';
import { TransactionService } from 'module/transaction/transaction.service';
import { ExchangeService } from 'service/exchange/exchange.service';
import waitForExpect from 'wait-for-expect';
import { bolt11Encode } from './mock/classes';
import { MockExchangeService } from './mock/classes/exchange.service.mock';
import { scaffoldGroup } from './mock/scaffold-group';
import { scaffoldTest } from './mock/scaffold-test';

scaffoldGroup('Settlement', (scaffold) => {
	const incomingTransaction = (entities, params = {}) => {
		const addr = bolt11Encode(1 * MSATOSHIS).paymentRequest;
		return {
			potId: entities.pot[0].id,
			type: 'bolt11',
			txid: bolt11.decode(addr).tagsObject.payment_hash,
			originalAddress: addr,
			address: addr,
			currencyCode: 'BTC',
			amount: 0.001,
			outgoing: false,
			status: true,
			...params,
		};
	};
	scaffoldTest(
		scaffold,
		'should execute trade when liabilities mismatched',
		async (entities) => {
			const originalFunc = (
				scaffold.app.get(ExchangeService) as MockExchangeService
			).buy.bind(
				scaffold.app.get(ExchangeService) as MockExchangeService
			);

			const mockedBuy = jest
				.spyOn(
					scaffold.app.get(ExchangeService) as MockExchangeService,
					'buy'
				)
				.mockImplementationOnce((...args) => {
					return originalFunc(...args);
				});

			const originalExchangeBuy = (
				scaffold.app.get(ExchangeService) as MockExchangeService
			).exchanges[0].trade.bind(
				(scaffold.app.get(ExchangeService) as MockExchangeService)
					.exchanges[0]
			);

			const mockedExchangeBuy = jest
				.spyOn(
					(scaffold.app.get(ExchangeService) as MockExchangeService)
						.exchanges[0],
					'trade'
				)
				.mockImplementationOnce((...args) => {
					return originalExchangeBuy(...args);
				});
			scaffold.app.get(Config).set({
				settle: true,
			});

			const { entity: pot2 } = await runAsUser(
				entities.user[0],
				async () =>
					await scaffold.app.get(PotService).create({
						name: 'USD pot',
						currency: 'USD',
					})
			);
			scaffold.app.get(TransactionService).create({
				...incomingTransaction(entities),
				potId: pot2.id,
				currencyCode: 'USD',
				amount: 10,
			});
			await waitForExpect(() => {
				const calls = mockedBuy.mock.calls;
				expect(calls.length).toBe(1);
				expect(calls[0][0]).toBe('USD');
				expect(calls[0][1]).toBe(10);

				const exchangeCalls = mockedExchangeBuy.mock.calls;
				expect(exchangeCalls.length).toBe(1);
				expect(exchangeCalls[0][0]).toBe('BTC');
				expect(exchangeCalls[0][1]).toBe('USDT');
				expect(exchangeCalls[0][2]).toBe(10);
			});
		}
	);

	// todo callback detectOpenHandles doesnt work because transaction callbacks executing after database wiped
});
