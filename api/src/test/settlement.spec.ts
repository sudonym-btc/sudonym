import { Config } from 'config/config';
import { PotService } from 'module/pot/pot.service';
import { TransactionService } from 'module/transaction/transaction.service';
import { ExchangeSettlerService } from 'service/exchange/exchange-settler.service';
import { ExchangeService } from 'service/exchange/exchange.service';
import waitForExpect from 'wait-for-expect';
import { MockExchangeSettlerService } from './mock/classes/exchange-settler.service.mock';
import { MockExchangeService } from './mock/classes/exchange.service.mock';
import { runAsUser, scaffoldGroup } from './mock/scaffold-group';

scaffoldGroup('Settlement', (scaffold) => {
	const incomingTransaction = (params = {}) => ({
		potId: scaffold.entities.pot[0].id,
		type: 'lnurl',
		originalAddress: 'lnurl23423',
		address: '32423432',
		currencyCode: 'BTC',
		amount: 0.001,
		outgoing: false,
		...params,
	});
	it('should execute trade when liabilties mismatched', async () => {
		scaffold.app.get(Config).set({
			settle: true,
		});

		const pot2 = await runAsUser(
			scaffold.entities.user[0],
			async () =>
				await scaffold.app.get(PotService).create({
					name: 'USD pot',
					currency: 'USD',
				})
		);
		const data = await scaffold.app.get(TransactionService).create({
			...incomingTransaction(),
			potId: pot2.id,
			currencyCode: 'USD',
			amount: 10,
		});

		await waitForExpect(() => {
			const calls = (
				scaffold.app.get(
					ExchangeSettlerService
				) as MockExchangeSettlerService
			).buy.mock.calls;
			expect(calls.length).toBe(1);
			expect(calls[0][0]).toBe('USD');
			expect(calls[0][1]).toBe(data.amount);

			const exchangeCalls = (
				scaffold.app.get(ExchangeService) as MockExchangeService
			).trade.mock.calls;
			expect(exchangeCalls.length).toBe(1);
			expect(exchangeCalls[0][0]).toBe('BTC');
			expect(exchangeCalls[0][1]).toBe('USDT');
			expect(exchangeCalls[0][2]).toBe(data.amount);
		});
	});

	// todo callback detectOpenHandles doesnt work because transaction callbacks executing after database wiped
});
