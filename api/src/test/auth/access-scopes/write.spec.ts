import { JwtService } from '@nestjs/jwt';
import * as request from 'supertest';
import { scaffoldTest } from 'test/mock/scaffold-test';
import { scaffoldGroup } from '../../mock/scaffold-group';

scaffoldGroup('Access Scopes', (scaffold) => {
	// scaffoldTest(scaffold,'should not be able to overwrite protected columns', () => {
	// 	return request(scaffold.app.getHttpServer()).post('/auth').expect(401);
	// });

	scaffoldTest(
		scaffold,
		'should not be able to overwrite pot balance',
		async (entities) => {
			const data = await request(scaffold.app.getHttpServer())
				.put('/pot/' + entities.pot[0].id)
				.set({
					'x-access-token': scaffold.app
						.get(JwtService)
						.sign({ uid: entities.user[0].firebaseId }),
				})
				.send({
					balance: 1000,
					spendableBalance: 1000,
				});

			expect(data.body.balance).not.toBe(1000);
			expect(data.body.spendableBalance).not.toBe(1000);
		}
	);

	scaffoldTest(
		scaffold,
		'should not be able to create pot balance',
		async (entities) => {
			const data = await request(scaffold.app.getHttpServer())
				.post('/pot')
				.set({
					'x-access-token': scaffold.app
						.get(JwtService)
						.sign({ uid: entities.user[0].firebaseId }),
				})
				.send({
					name: 'test',
					currency: 'BTC',
					balance: 1000,
					spendableBalance: 1000,
				});

			expect(data.body.balance).not.toBe(1000);
			expect(data.body.spendableBalance).not.toBe(1000);
		}
	);

	// scaffoldTest(scaffold,'should not be able to change transaction amount balance', () => {

	// });

	// scaffoldTest(scaffold,'should not be able to create a transaction in a pot not belonging to user', () => {
	// 	return request(scaffold.app.getHttpServer())
	// 		.post('/transaction')
	// 		.set({
	// 			'x-access-token': scaffold.app
	// 				.get(JwtService)
	// 				.sign({ uid: entities.user[0].firebaseId }),
	// 		})
	// 		.send({
	// 			outgoing: true,
	// 			address: exampleInvoice,
	// 			originalAddress: exampleInvoice,
	// 			potId: newPot.id,
	// 			amount: 1,
	// 			currencyCode: 'BTC',
	// 		})
	// 		.expect((d) => {
	// 			expect(d.body.balance).not.toBe(1000);
	// 			expect(d.body.spendableBalance).not.toBe(1000);
	// 		});
	// });
});
