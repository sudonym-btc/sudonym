import { TransactionService } from 'module/transaction/transaction.service';
import { exampleInvoice } from './bill-split.spec';
import { scaffoldGroup } from './mock/scaffold-group';

scaffoldGroup('CRUD', (scaffold) => {
	it('should include scope single', async () => {
		const { entity: transaction } = await scaffold.app
			.get(TransactionService)
			.create({
				outgoing: true,
				potId: scaffold.entities.pot[0].id,
				type: 'bolt11',
				currencyCode: 'BTC',
				originalAddress: 'lnurl123',
				address: exampleInvoice,
				amount: 1,
			});

		expect(transaction.Pot).toBeTruthy();
	});
});
