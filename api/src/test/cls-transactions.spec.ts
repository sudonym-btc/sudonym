import { scaffoldGroup } from './mock/scaffold-group';
import { scaffoldTest } from './mock/scaffold-test';

scaffoldGroup('CLS transactions', (scaffold) => {
	scaffoldTest(
		scaffold,
		'should emit events when successful',
		async () => {}
	);

	scaffoldTest(scaffold, 'should not emit if error caught', async () => {
		// scaffold.app.get(TransactionService).create({
		// 	outgoing: true,
		// 	potId: entities.pot[0].id,
		// 	type: 'bolt11',
		// 	currencyCode: 'BTC',
		// 	originalAddress: exampleInvoice,
		// 	address: exampleInvoice,
		// 	status: true,
		// 	amount: 10000,
		// });
		// await new Promise((resolve, reject) => {
		// 	scaffold.app.get(EventsService).onEvent.subscribe((e) => {
		// 		console.log(e);
		// 		if(e.event.name == 'transaction.created') reject()
		// 	});
		// 	setTimeout(() => resolve(true), 2000);
		// });
	});
});
