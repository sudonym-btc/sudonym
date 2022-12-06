import * as request from 'supertest';
import { scaffoldGroup } from './mock/scaffold-group';

scaffoldGroup('Lightning Address', (scaffold) => {
	it('should return pr when query endpoint', async () => {
		const data = await request(scaffold.app.getHttpServer()).get(
			'/.well-known/lnurlp/' + scaffold.entities.user[0].lightningAddress
		);
		expect(data.body.tag).toBe('payRequest');
		const callback = await request(scaffold.app.getHttpServer()).get(
			data.body.callback.split('sudonym.app').pop() + '?amount=500'
		);
		expect(callback.body.pr).toBeTruthy();
	});
});
