import { Contact } from '../classes/contact';
import { factory as contactAddressFactory } from './contact-address.mock';
import { mocks as userMocks } from './user.mock';

import { faker } from '@faker-js/faker';
import * as Factory from 'factory.ts';
import { RecursivePartial } from '../recursive-partial';

export const factory = Factory.Sync.makeFactory<RecursivePartial<Contact>>({
	id: Factory.each((i) => i),
	userId: faker.helpers.arrayElement(userMocks.map((u) => u.id)),
	name: Factory.each((i) => faker.name.firstName()),
	ContactAddresses: contactAddressFactory.buildList(2),
});
export const mocks = factory.buildList(20);
