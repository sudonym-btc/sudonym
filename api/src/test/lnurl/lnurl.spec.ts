import { ActionService } from 'module/action/action.service';
import { ReceiverService } from 'module/receiver/receiver.service';
import { scaffoldGroup } from '../mock/scaffold-group';

scaffoldGroup('LnUrl', (scaffold) => {
	describe('do', () => {
		describe('Withdraw', () => {
			it('should fetch and withdraw to pot', async () => {
				const url = 'lnurlw://coincorner.com/lnurlw';
				const info = await scaffold.app.get(ActionService).parse(url);
				console.log(info);
				expect(info.withdraw).toBeTruthy();
				const execute = await scaffold.app
					.get(ActionService)
					.execute(info.withdraw);
				console.log(execute);
			});
		});

		describe('Pay', () => {
			it('should limit based on pot spendable balance', () => {});
		});
	});

	describe('serve', () => {
		describe('Withdraw', () => {
			it('should limit based on max payment', () => {});
			it('should limit based on min payment', () => {});
		});
		describe('Pay', () => {
			it('should serve info endpoint', () => {});
			it('should serve callback endpoint with correct bolt11', () => {});

			describe('lightningAddress', () => {
				it('should serve info endpoint', () => {});
			});
		});
	});
});
