import * as Factory from "factory.ts";
import { ContactAddress } from "../classes/contact-address";

(Array.prototype as any).random = function () {
    return this[Math.floor((Math.random() * this.length))];
}

export const factory = Factory.Sync.makeFactory<Partial<ContactAddress>>({
    // id: Factory.each(i => i.toString()),
    contactId: Factory.each(i => i),
    addressType: (['lnurl'] as any).random(),
    address: (['lnurl23234342423'] as any).random(),
    name: 'Muun'
});
export const mocks = factory.buildList(20);