import { JwtService } from '@nestjs/jwt';
import { MSATOSHIS } from '@sudonym/models';
import { runAsUser } from 'helper/context-request';
import { ContactService } from 'module/contact/contact.service';
import { TransactionService } from 'module/transaction/transaction.service';
import * as request from 'supertest';
import { bolt11Encode } from './mock/classes';
import { scaffoldGroup } from './mock/scaffold-group';
import { scaffoldTest } from './mock/scaffold-test';

scaffoldGroup('Payment Contacts', (scaffold) => {
	scaffoldTest(
		scaffold,
		'should allocate contactAddress id to transaction if recognized',
		async (entities) => {
			const { entity: contact } = await scaffold.app
				.get(ContactService)
				.create({
					userId: entities.user[0].id,
					name: 'testing',
					ContactAddresses: [
						{
							address:
								'lnurl123' +
								Math.random().toString().replace('.', ''),
						},
					],
				});
			const { entity: transaction } = await scaffold.app
				.get(TransactionService)
				.create({
					outgoing: true,
					potId: entities.pot[0].id,
					type: 'bolt11',
					currencyCode: 'BTC',
					originalAddress: contact.ContactAddresses[0].address,
					address: bolt11Encode(1 * MSATOSHIS).paymentRequest,
					amount: 1,
				});
			expect(transaction.contactAddressId).toBe(
				contact.ContactAddresses[0].id
			);
		}
	);

	scaffoldTest(
		scaffold,
		'should assign transaction contact address id on contact create',
		async (entities) => {
			const addr = bolt11Encode(1 * MSATOSHIS).paymentRequest;
			const { entity: transaction } = await scaffold.app
				.get(TransactionService)
				.create({
					outgoing: true,
					potId: entities.pot[0].id,
					type: 'bolt11',
					currencyCode: 'BTC',
					originalAddress: addr,
					address: addr,
					amount: 1,
				});
			const { entity: contact } = await scaffold.app
				.get(ContactService)
				.create({
					userId: entities.user[0].id,
					name: 'testing',
					ContactAddresses: [
						{
							address: transaction.originalAddress,
						},
					],
				});

			const tx = await scaffold.app
				.get(TransactionService)
				.findOne(transaction.id);

			expect(tx.contactAddressId).toBe(contact.ContactAddresses[0].id);
		}
	);

	scaffoldTest(scaffold, 'should search contacts', async (entities) => {
		await runAsUser(entities.user[0], async () => {
			await scaffold.app.get(ContactService).create({
				name: 'john',
				ContactAddresses: [
					{ address: 'john@email.com', addressType: 'lnurl' },
				],
			});
		});
		let contacts = await request(scaffold.app.getHttpServer())
			.get(
				'/contact?where%5Bname%5D%5Blike%5D=s&where%5Bid%5D%5Blt%5D=99999999999999&order%5B0%5D=id&order%5B0%5D=DESC'
			)
			.set({
				'x-access-token': scaffold.app
					.get(JwtService)
					.sign({ uid: entities.user[0].firebaseId }),
			});

		expect(contacts.body.data.length).toBe(0);

		contacts = await request(scaffold.app.getHttpServer())
			.get(
				'/contact?where%5Bname%5D%5Blike%5D=john&where%5Bid%5D%5Blt%5D=99999999999999&order%5B0%5D=id&order%5B0%5D=DESC'
			)
			.set({
				'x-access-token': scaffold.app
					.get(JwtService)
					.sign({ uid: entities.user[0].firebaseId }),
			});

		expect(contacts.body.data.length).toBe(1);
		expect(contacts.body.data[0].name).toBe('john');
	});
});
