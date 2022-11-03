import { BaseClass } from './base-class';
import { ContactAddress } from './contact-address';

export class Contact extends BaseClass {
	constructor(
		public id: number | null,
		public userId: string | null,
		public name: string | null,
		public ContactAddresses: ContactAddress[]
	) {
		super();
	}

	static fromJson(json: Object): Contact {
		const addresses: ContactAddress[] = [];
		(json['ContactAddresses'] != null
			? json['ContactAddresses']
			: []
		).forEach((e) => {
			addresses.push(ContactAddress.fromJson(e));
		});
		return new Contact(json['id'], json['userId'], json['name'], addresses);
	}

	toJson(): any {
		const addresses: Object[] = [];
		this.ContactAddresses.forEach((e) => {
			addresses.push(e.toJson());
		});
		return {
			id: this.id,
			userId: this.userId,
			name: this.name,
			ContactAddresses: addresses,
		};
	}
}
