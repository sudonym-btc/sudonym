import { JwtService } from '@nestjs/jwt';
import * as request from 'supertest';
import { scaffoldGroup } from '../../mock/scaffold-group';

scaffoldGroup('Access Scopes', (scaffold) => {
	// it('should not be able to overwrite protected columns', () => {
	// 	return request(scaffold.app.getHttpServer()).post('/auth').expect(401);
	// });

	it('should not be able to overwrite pot balance', async () => {
		const data = await request(scaffold.app.getHttpServer())
			.put('/pot/' + scaffold.entities.pot[0].id)
			.set({
				'x-access-token': scaffold.app
					.get(JwtService)
					.sign({ uid: scaffold.entities.user[0].firebaseId }),
			})
			.send({
				balance: 1000,
				spendableBalance: 1000,
			});

			expect(data.body.balance).not.toBe(1000);
			expect(data.body.spendableBalance).not.toBe(1000);
	});

	it('should not be able to create pot balance', async () => {
		const data = await request(scaffold.app.getHttpServer())
			.post('/pot')
			.set({
				'x-access-token': scaffold.app
					.get(JwtService)
					.sign({ uid: scaffold.entities.user[0].firebaseId }),
			})
			.send({
				name: 'test',
				currency: 'BTC',
				balance: 1000,
				spendableBalance: 1000,
			});

			expect(data.body.balance).not.toBe(1000);
			expect(data.body.spendableBalance).not.toBe(1000);
	});

	// it('should not be able to change transaction amount balance', () => {

	// });

	// it('should not be able to create a transaction in a pot not belonging to user', () => {
	// 	return request(scaffold.app.getHttpServer())
	// 		.post('/transaction')
	// 		.set({
	// 			'x-access-token': scaffold.app
	// 				.get(JwtService)
	// 				.sign({ uid: scaffold.entities.user[0].firebaseId }),
	// 		})
	// 		.send({
	// 			outgoing: true,
	// 			address: 'lnbc1asdfghj',
	// 			originalAddress: 'lnbc1asdfghj',
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
