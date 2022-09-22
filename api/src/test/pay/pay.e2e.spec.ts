import * as request from 'supertest';
import { scaffoldGroup } from '../mock/scaffold-group';
import { USER_PASSWORD } from '../mock/user';

scaffoldGroup('PaymentController (e2e)', (scaffold) => {
	describe('Invoice', () => {
		const endpoint = '/payment/payInvoice';

		it(endpoint + ' (POST) should fail without login', () => {
			// return request(scaffold.app.getHttpServer())
			// 	.post(endpoint)
			// 	.expect(401);
		});

		it(endpoint + ' (POST) should fail with no balance', () => {
			// return request(scaffold.app.getHttpServer())
			// 	.post(endpoint)
			// 	.expect(401);
		});

		it(endpoint + ' (POST) should succeed', () => {
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

		// it(endpoint + ' (GET) should fail without login', () => {
		// 	return request(scaffold.app.getHttpServer())
		// 		.get(endpoint)
		// 		.expect(401);
		// });

		// it(endpoint + ' (GET) should fail without login', () => {
		// 	return request(scaffold.app.getHttpServer())
		// 		.get(endpoint)
		// 		.expect(401);
		// });

		// it(endpoint + ' (GET) should succeed for bolt11', () => {
		// 	return request(scaffold.app.getHttpServer())
		// 		.get(endpoint)
		// 		.send({
		// 			pass: USER_PASSWORD,
		// 		})
		// 		.expect(200);
		// });

		// it(endpoint + ' (GET) should succeed for bolt12', () => {
		// 	return request(scaffold.app.getHttpServer())
		// 		.get(endpoint)
		// 		.send({
		// 			pass: USER_PASSWORD,
		// 		})
		// 		.expect(200);
		// });

		// it(endpoint + ' (GET) should succeed for lnurl', () => {
		// 	return request(scaffold.app.getHttpServer())
		// 		.get(endpoint)
		// 		.send({
		// 			pass: USER_PASSWORD,
		// 		})
		// 		.expect(200);
		// });
	});
});
