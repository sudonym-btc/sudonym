import { TransactionService } from 'module/transaction/transaction.service';
import { scaffoldGroup } from '../mock/scaffold-group';

scaffoldGroup('Transaction Access', (scaffold) => {
	test('should test user ids transaction', async () => {
		await scaffold.app.get(TransactionService).create({
			potId: scaffold.entities.pot[0].id,
			amount: 1,
			outgoing: true,
			originalAddress: 'lnb',
			address: 'lnbc',
		});
	});

	//TODO CHECK TRANSACTION CURRENCY BEFORE SENDING ANYWHERE
	// TODO CHECK AMOUNT OF SATS REPORTED IS SAME AS CONVERTED RATE
});
