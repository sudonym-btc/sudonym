import { AddressParser } from 'module/action/address-parser/address-parser';
import { ContactService } from 'module/contact/contact.service';
import { ReceiverService } from 'module/receiver/receiver.service';
import * as request from 'supertest';
import { scaffoldGroup } from './mock/scaffold-group';

scaffoldGroup('Validation', (scaffold) => {
	it('DTO validation error should be in same format as DB validation', async () => {
		const data = await request(scaffold.app.getHttpServer()).get(
			'/receiver/invoice?amount=str'
		);

		expect(data.statusCode).toBe(400);
		expect(data.body);
		console.log(data.body);

		const response = scaffold.app.get(ReceiverService).create({
			potId: scaffold.entities.pot[0].id,
			type: 'lnurl',
			amount: 'str',
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
					address: 'lnurl32423423',
				},
			],
		} as any);

		const second = await scaffold.app.get(ContactService).createOrUpdate({
			name: 'tester',
			userId: scaffold.entities.user[0].id,
			ContactAddresses: [
				{
					address: 'lnurl32423423',
				},
			],
		} as any);

		expect(first.id).toBe(second.id);
		expect(second.ContactAddresses.length).toBe(1);
	});

	it('should classify address types correctly', async () => {
		const addresses = {
			onchain: [],
			bolt11: [
				'lnbc1p3kggh9pp5ax50adfnnltg0a2evqapx9dfxuyv6904z880ytu2ywmx6aktxfxqdqu2askcmr9wssx7e3q2dshgmmndp5scqzpgxqyz5vqsp5353ne50r6tt5aprppnhnyn3mj3aqyc6pz8vm70543z54x09qxr6s9qyyssq2z9nvel938mvptmk27qnfa6yza6xx8l67sv4lvyju26s7208njtz2fm8hmmvhf675m4jur7z9j67jx3z0zetzlwcnshu7gmngdg6g4qpvn00xh', // without amount
				'lnbcrt9849383230p1p3kgwy7sp5t5e3n4w60dxntfvejf7xssscn9r4rs533a937mgeyejuhaqragtspp55qjjg0g67txkkxd2ttay0r0f2me3ggq9eghfrepy9k9kxamlxdhqdp6x93k2en98yckgtf5xymxxtf5xe3k2tfcx9nxztf3vyerzdrpxdjr2vrxvyxqyjw5qcqp29qyysgqsyjr8pzfzejavzuec9zx502v68vp47vennf5cctt3nqgllym6s9xsvjy7ced9sz7yy80qldpgyfkvaxqwtqn7dtawf0uvrakl7kcw7gpff0gxy', // with amount
			],
			lnurl: [
				'lnurl1dp68gurn8ghj7ctsdyhxcmmrv9kzuer9wejkcmmsd4jkuap0d3h82unv9ajnycejxcuxyvpdvscrvwfdxsukgved8ycn2d3dvenrjcm9xcerydfevgms35vlmv',
			],
		};

		for (const section of Object.keys(addresses)) {
			for (const addr of addresses[section]) {
				expect(scaffold.app.get(AddressParser).getType(addr)[0]).toBe(
					section
				);
			}
		}
	});
});
