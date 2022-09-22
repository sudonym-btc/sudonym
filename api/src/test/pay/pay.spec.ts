import { scaffoldGroup } from '../mock/scaffold-group';

scaffoldGroup('Payment', (scaffold) => {
	describe('Bolt11', () => {
		it('should subtract balance from executed payment', () => { });
		it('should re-add balance from failed payment', () => { });
	});

	describe('Bolt12', () => {
		it('should subtract balance from executed payment', () => { });
		it('should re-add balance from failed payment', () => { });
	});

	describe('lnurl', () => {
		it('should subtract balance from executed payment', () => { });
		it('should re-add balance from failed payment', () => { });
	});

	describe('lightningAddress', () => {
		it('should subtract balance from executed payment', () => { });
		it('should re-add balance from failed payment', () => { });
	});

	describe('onchain', () => {
		it('should subtract balance from executed payment', () => { });
		it('should re-add balance from failed payment', () => { });
	});
});
