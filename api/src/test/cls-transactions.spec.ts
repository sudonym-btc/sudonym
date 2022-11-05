import { scaffoldGroup } from './mock/scaffold-group';

scaffoldGroup('CLS transactions', (scaffold) => {
	it('should emit events when successful', async () => {});

	it('should not emit if error caught', async () => {
		// scaffold.app.get(TransactionService).create({
		// 	outgoing: true,
		// 	potId: scaffold.entities.pot[0].id,
		// 	type: 'bolt11',
		// 	currencyCode: 'BTC',
		// 	originalAddress: 'lnbc1asdfghj',
		// 	address: 'lnbc1asdfghj',
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
