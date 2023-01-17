import { scaffoldTest } from 'test/mock/scaffold-test';
import { scaffoldGroup } from '../mock/scaffold-group';

scaffoldGroup('AuthController (e2e)', (scaffold) => {
	scaffoldTest(scaffold, '/auth (POST) should fail without password', () => {
		// return request(scaffold.app.getHttpServer()).post('/auth').expect(401);
	});

	scaffoldTest(
		scaffold,
		'/auth (POST) should fail with wrong password',
		() => {
			// return request(scaffold.app.getHttpServer()).post('/auth').expect(401);
		}
	);

	scaffoldTest(scaffold, '/auth (POST) should succeed', () => {
		// return request(scaffold.app.getHttpServer())
		// 	.post('/auth')
		// 	.send({
		// 		pass: USER_PASSWORD,
		// 	})
		// 	.expect(200);
	});
});
