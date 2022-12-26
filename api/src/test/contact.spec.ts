import { JwtService } from '@nestjs/jwt';
import { runAsUser } from 'helper/context-request';
import { ContactService } from 'module/contact/contact.service';
import { TransactionService } from 'module/transaction/transaction.service';
import * as request from 'supertest';
import { scaffoldGroup } from './mock/scaffold-group';

scaffoldGroup('Payment Contacts', (scaffold) => {
	it('should allocate contactAddress id to transaction if recognized', async () => {
		const { entity: contact } = await scaffold.app
			.get(ContactService)
			.create({
				userId: scaffold.entities.user[0].id,
				name: 'testing',
				ContactAddresses: [
					{
						address: 'lnurl123',
					},
				],
			});
		const { entity: transaction } = await scaffold.app
			.get(TransactionService)
			.create({
				outgoing: true,
				potId: scaffold.entities.pot[0].id,
				type: 'bolt11',
				currencyCode: 'BTC',
				originalAddress: 'lnurl123',
				address: 'lnurl123',
				amount: 1,
			});
		expect(transaction.contactAddressId).toBe(
			contact.ContactAddresses[0].id
		);
	});

	it('should assign transaction contact address id on contact create', async () => {
		const { entity: transaction } = await scaffold.app
			.get(TransactionService)
			.create({
				outgoing: true,
				potId: scaffold.entities.pot[0].id,
				type: 'bolt11',
				currencyCode: 'BTC',
				originalAddress: 'lnurl123',
				address: 'lnurl123',
				amount: 1,
			});
		const { entity: contact } = await scaffold.app
			.get(ContactService)
			.create({
				userId: scaffold.entities.user[0].id,
				name: 'testing',
				ContactAddresses: [
					{
						address: 'lnurl123',
					},
				],
			});

		const tx = await scaffold.app
			.get(TransactionService)
			.findOne(transaction.id);

		expect(tx.contactAddressId).toBe(contact.ContactAddresses[0].id);
	});

	it('should search contacts', async () => {
		await runAsUser(scaffold.entities.user[0], async () => {
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
					.sign({ uid: scaffold.entities.user[0].firebaseId }),
			});

		expect(contacts.body.data.length).toBe(0);

		contacts = await request(scaffold.app.getHttpServer())
			.get(
				'/contact?where%5Bname%5D%5Blike%5D=john&where%5Bid%5D%5Blt%5D=99999999999999&order%5B0%5D=id&order%5B0%5D=DESC'
			)
			.set({
				'x-access-token': scaffold.app
					.get(JwtService)
					.sign({ uid: scaffold.entities.user[0].firebaseId }),
			});

		expect(contacts.body.data.length).toBe(1);
		expect(contacts.body.data[0].name).toBe('john');
	});
});
