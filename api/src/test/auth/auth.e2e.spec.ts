import * as request from 'supertest';
import { scaffoldGroup } from '../mock/scaffold-group';
import { USER_PASSWORD } from '../mock/user';

scaffoldGroup('AuthController (e2e)', (scaffold) => {
	it('/auth (POST) should fail without password', () => {
		// return request(scaffold.app.getHttpServer()).post('/auth').expect(401);
	});

	it('/auth (POST) should fail with wrong password', () => {
		// return request(scaffold.app.getHttpServer()).post('/auth').expect(401);
	});

	it('/auth (POST) should succeed', () => {
		// return request(scaffold.app.getHttpServer())
		// 	.post('/auth')
		// 	.send({
		// 		pass: USER_PASSWORD,
		// 	})
		// 	.expect(200);
	});
});
