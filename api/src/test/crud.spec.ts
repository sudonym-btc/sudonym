import { MSATOSHIS } from '@sudonym/models';
import { TransactionService } from 'module/transaction/transaction.service';
import { bolt11Encode } from './mock/classes';
import { scaffoldGroup } from './mock/scaffold-group';
import { scaffoldTest } from './mock/scaffold-test';

scaffoldGroup('CRUD', (scaffold) => {
	scaffoldTest(scaffold, 'should include scope single', async (entities) => {
		const { entity: transaction } = await scaffold.app
			.get(TransactionService)
			.create({
				outgoing: true,
				potId: entities.pot[0].id,
				type: 'bolt11',
				currencyCode: 'BTC',
				originalAddress:
					'lnurl123' + Math.random().toString().replace('.', ''),
				address: bolt11Encode(1 * MSATOSHIS).paymentRequest,
				amount: 1,
			});

		expect(transaction.Pot).toBeTruthy();
	});
});
