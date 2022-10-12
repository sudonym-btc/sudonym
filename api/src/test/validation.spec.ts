import { scaffoldGroup } from './mock/scaffold-group';
import * as request from 'supertest';
import { ReceiverService } from 'module/receiver/receiver.service';

scaffoldGroup('Validation', (scaffold) => {

	it('DTO validation error should be in same format as DB validation', async () => {
		const data = await request(scaffold.app.getHttpServer())
			.get('/receiver/invoice?amount=str');

		expect(data.statusCode).toBe(400);
		expect(data.body)

		console.log(data.body);

		try {
			console.log(await scaffold.app.get(ReceiverService).getInvoice({
				potId: scaffold.entities.pot[0].id,
				type: 'lnurl',
				amount: 'str'
			} as any));
		} catch (e) {
			console.error(e);
		}


		// @todo: Compare that errors are returned the same way
	});

});
