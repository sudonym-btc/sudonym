import { JwtService } from '@nestjs/jwt';
import * as request from 'supertest';
import { scaffoldGroup } from './mock/scaffold-group';

scaffoldGroup('User', (scaffold) => {
	it('should create new user', async () => {
		const data = await request(scaffold.app.getHttpServer())
			.post('/user')
			.send({
				firebaseId: 'longfbif',
				id: 'longfbif',
			})
			.set({
				'x-access-token': scaffold.app
					.get(JwtService)
					.sign({ uid: 'longfbif' }),
			});
		expect(data.body.id).toBeTruthy();
		expect(data.body.lightningAddress).toBeTruthy();
	});

	it('should not allow duplicate lightningAddress', async () => {
		const data = await request(scaffold.app.getHttpServer())
			.post('/user')
			.set({
				'x-access-token': scaffold.app
					.get(JwtService)
					.sign({ uid: 'longfbif' }),
			})
			.send({
				lightningAddress: scaffold.entities.user[0].lightningAddress,
				firebaseId: 'longfbif',
				id: 'longfbif',
			});
		expect(data.status).toBe(400);
	});
});
