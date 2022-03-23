
export class ContactAddress {

    constructor(
        public contactId: string,
        public addressType: string,
        public address: string,
        public name: string
    ) { }

    static fromJson(json: Object): ContactAddress {
        return new ContactAddress(
            json["contactId"],
            json["addressType"],
            json["address"],
            json["name"],
        );
    }
}