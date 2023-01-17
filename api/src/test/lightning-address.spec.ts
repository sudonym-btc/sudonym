import * as request from 'supertest';
import { scaffoldGroup } from './mock/scaffold-group';
import { scaffoldTest } from './mock/scaffold-test';

scaffoldGroup('Lightning Address', (scaffold) => {
	scaffoldTest(
		scaffold,
		'should return pr when query endpoint',
		async (entities) => {
			const data = await request(scaffold.app.getHttpServer()).get(
				'/.well-known/lnurlp/' + entities.user[0].lightningAddress
			);
			expect(data.body.tag).toBe('payRequest');
			const callback = await request(scaffold.app.getHttpServer()).get(
				data.body.callback.split('sudonym.app').pop() + '?amount=500'
			);
			expect(callback.body.pr).toBeTruthy();
		}
	);
});
