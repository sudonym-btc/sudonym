import { BaseClass } from './base-class';

export class ContactAddress extends BaseClass {
	constructor(
		public contactId: number,
		public addressType: string,
		public address: string,
		public name: string
	) {
		super();
	}

	static fromJson(json: Object): ContactAddress {
		return new ContactAddress(
			json['contactId'],
			json['addressType'],
			json['address'],
			json['name']
		);
	}

	toJson(): any {
		return {
			contactId: this.contactId,
			addressType: this.addressType,
			address: this.address,
			name: this.name,
		};
	}
}
