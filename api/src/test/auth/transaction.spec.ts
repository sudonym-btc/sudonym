import { TransactionService } from 'module/transaction/transaction.service';
import { scaffoldTest } from 'test/mock/scaffold-test';
import { scaffoldGroup } from '../mock/scaffold-group';

scaffoldGroup('Transaction Access', (scaffold) => {
	scaffoldTest(
		scaffold,
		'should test user ids transaction',
		async (entities) => {
			await scaffold.app.get(TransactionService).create({
				potId: entities.pot[0].id,
				amount: 1,
				outgoing: true,
				originalAddress: 'lnb',
				address: 'lnbc',
			});
			// todo complete this
		}
	);

	scaffoldTest(
		scaffold,
		'should add userId to transaction if user is creating it',
		(entities) => {}
	);
});
