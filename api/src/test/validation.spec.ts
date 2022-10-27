import { scaffoldGroup } from './mock/scaffold-group';
import * as request from 'supertest';
import { ReceiverService } from 'module/receiver/receiver.service';
import { ContactService } from 'module/contact/contact.service';

scaffoldGroup('Validation', (scaffold) => {

	it('DTO validation error should be in same format as DB validation', async () => {
		const data = await request(scaffold.app.getHttpServer())
			.get('/receiver/invoice?amount=str');

		expect(data.statusCode).toBe(400);
		expect(data.body)

		const response = scaffold.app.get(ReceiverService).create({
				potId: scaffold.entities.pot[0].id,
				type: 'lnurl',
				amount: 'str'
			} as any);

		await expect(response).rejects.toThrowError();


		// todo: Compare that errors are returned the same way
	});

	it('create or update unique keys', async () => {

		const first = await scaffold.app.get(ContactService).createOrUpdate({
			userId: scaffold.entities.user[0].id,
			name: 'tester',
			ContactAddresses: [
				{
					address: 'lnurl32423423'
				}
			]
		} as any);

		const second = await scaffold.app.get(ContactService).createOrUpdate({
			name: 'tester',
			userId: scaffold.entities.user[0].id,
			ContactAddresses: [
				{
					address: 'lnurl32423423'
				}
			]
		} as any);

		expect(first.id).toBe(second.id);
		expect(second.ContactAddresses.length).toBe(1);
	});

});
