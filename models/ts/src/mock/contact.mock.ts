import { Contact } from "classes/contact";
import {factory as contactAddressFactory} from "./contact-address.mock";

import * as Factory from "factory.ts";
import faker from "@faker-js/faker";

export const factory = Factory.Sync.makeFactory<Contact>({
    id: Factory.each(i => i.toString()),
    userId: Factory.each(i => i.toString()),
    name:  Factory.each(i => faker.name.firstName()),
    ContactAddresses: contactAddressFactory.buildList(2)
});
export const mocks = factory.buildList(20);