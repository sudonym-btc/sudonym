import { scaffoldTest } from 'test/mock/scaffold-test';
import { scaffoldGroup } from '../mock/scaffold-group';

scaffoldGroup('PaymentController (e2e)', (scaffold) => {
	describe('Invoice', () => {
		const endpoint = '/payment/payInvoice';

		scaffoldTest(
			scaffold,
			endpoint + ' (POST) should fail without login',
			() => {
				// return request(scaffold.app.getHttpServer())
				// 	.post(endpoint)
				// 	.expect(401);
			}
		);

		scaffoldTest(
			scaffold,
			endpoint + ' (POST) should fail with no balance',
			() => {
				// return request(scaffold.app.getHttpServer())
				// 	.post(endpoint)
				// 	.expect(401);
			}
		);

		scaffoldTest(scaffold, endpoint + ' (POST) should succeed', () => {
			// return request(scaffold.app.getHttpServer())
			// 	.post(endpoint)
			// 	.send({
			// 		pass: USER_PASSWORD,
			// 	})
			// 	.expect(200);
		});
	});

	describe('Invoice Info', () => {
		// const endpoint = '/payment/getInfo';
		// scaffoldTest(scaffold,endpoint + ' (GET) should fail without login', () => {
		// 	return request(scaffold.app.getHttpServer())
		// 		.get(endpoint)
		// 		.expect(401);
		// });
		// scaffoldTest(scaffold,endpoint + ' (GET) should fail without login', () => {
		// 	return request(scaffold.app.getHttpServer())
		// 		.get(endpoint)
		// 		.expect(401);
		// });
		// scaffoldTest(scaffold,endpoint + ' (GET) should succeed for bolt11', () => {
		// 	return request(scaffold.app.getHttpServer())
		// 		.get(endpoint)
		// 		.send({
		// 			pass: USER_PASSWORD,
		// 		})
		// 		.expect(200);
		// });
		// scaffoldTest(scaffold,endpoint + ' (GET) should succeed for bolt12', () => {
		// 	return request(scaffold.app.getHttpServer())
		// 		.get(endpoint)
		// 		.send({
		// 			pass: USER_PASSWORD,
		// 		})
		// 		.expect(200);
		// });
		// scaffoldTest(scaffold,endpoint + ' (GET) should succeed for lnurl', () => {
		// 	return request(scaffold.app.getHttpServer())
		// 		.get(endpoint)
		// 		.send({
		// 			pass: USER_PASSWORD,
		// 		})
		// 		.expect(200);
		// });
	});
});
