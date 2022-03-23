import { ContactAddress } from "./contact-address";

export class Contact {

    constructor(
        public id: string,
        public userId: string,
        public name: string,
        public ContactAddresses: ContactAddress[]
    ) { }

    static fromJson(json: Object): Contact {
        let addresses: ContactAddress[] = [];
        json["ContactAddresses"].forEach((e) => {
            addresses.push(ContactAddress.fromJson(e));
        })
        return new Contact(
            json["id"],
            json["userId"],
            json["name"],
            addresses
        );
    }
}