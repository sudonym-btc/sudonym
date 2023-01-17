import { scaffoldTest } from 'test/mock/scaffold-test';
import { scaffoldGroup } from '../mock/scaffold-group';

scaffoldGroup('Pot Access', (scaffold) => {
	scaffoldTest(scaffold, 'should test user ids', async (entities) => {
		// await scaffold.app.get(PotService).create({
		// 	name: 'test',
		// 	currency: 'BTC',
		// });
		// todo
	});
});
