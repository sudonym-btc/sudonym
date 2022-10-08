import { MSATOSHIS, PaymentRequest, WithdrawRequest } from '@sudonym/models';
import { ActionService } from 'module/action/action.service';
import { LightningAddressController } from 'module/lightning/lnurl/lightning-address/lightning-address.controller';
import { LnUrlHandlerService } from 'module/lightning/lnurl/lnurl-handler/lnurl-handler.service';
import { LnUrlService } from 'module/lightning/lnurl/lnurl.service';
import { ReceiverService } from 'module/receiver/receiver.service';
import { SenderService } from 'module/sender/sender.service';
import { scaffoldGroup } from '../mock/scaffold-group';

scaffoldGroup('LnUrl', (scaffold) => {
	describe('do', () => {
		describe('Withdraw', () => {
			it('should fetch and withdraw to pot', async () => {
				const url = 'lnurlw://coincorner.com/lnurlw';
				const info = await scaffold.app.get(ActionService).parse(url);
				expect(info.withdraw).toBeTruthy();
				const execute = await scaffold.app
					.get(ActionService)
					.execute(info.withdraw);
			});
		});

		describe('Pay', () => {
			it('should limit based on pot spendable balance', () => { });
		});
	});

	describe('serve', () => {
		describe('Withdraw', () => {
			it('should limit based on max payment', async () => {
				const sender = await scaffold.app.get(SenderService).create({
					potId: scaffold.entities.pot[0].id,
					type: 'lnurl',
					limitMax: 1,
					limitMin: 0.2,
					amountCurrency: 'BTC',
				});

				const tag = await scaffold.app
					.get(LnUrlService)
					.serve(sender.lnurlId) as WithdrawRequest;

				expect(tag.minWithdrawable).toBe(sender.limitMin * MSATOSHIS);
				expect(tag.maxWithdrawable).toBe(sender.limitMax * MSATOSHIS);
			});
			it('should limit based on min payment', () => { });
		});
		describe('Pay', () => {
			it('should serve info endpoint', async () => {
				const receiver = await scaffold.app
					.get(ReceiverService)
					.create({
						potId: scaffold.entities.pot[0].id,
						type: 'lnurl',
						amountCurrency: 'BTC',
						amount: 1,
					});

				const tag = (await scaffold.app
					.get(LnUrlService)
					.serve(receiver.lnurlId)) as PaymentRequest;
				expect(tag.minSendable).toBe(receiver.amount * MSATOSHIS);
			});
			it('should serve callback endpoint with correct bolt11', async () => {
				const receiver = await scaffold.app
					.get(ReceiverService)
					.create({
						potId: scaffold.entities.pot[0].id,
						type: 'lnurl',
						amountCurrency: 'BTC',
						amount: 1,
					});

				const tag = await scaffold.app
					.get(LnUrlHandlerService)
					.handle(receiver.lnurlId, {
						amount: 1000,
					});
				console.log(tag);
				// expect(tag.pr); @TODO: parse pr to check it has right amount
			});

			describe('lightningAddress', () => {
				it('should serve info endpoint', async () => {
					const p = await scaffold.app.get(LightningAddressController)
						.lightningAddress(scaffold.entities.user[0].lightningAddress) as PaymentRequest;
					
					expect(p.minSendable).toBe(0);
					expect(p.tag).toBe('payRequest');
				});
			});
		});
	});
});
