import { BaseClass } from './base-class';

export class ContactAddress extends BaseClass {
	constructor(
		public contactId: number | null,
		public addressType: string | null,
		public address: string | null,
		public name: string | null
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
