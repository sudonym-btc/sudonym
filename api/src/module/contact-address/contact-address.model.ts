import { Table, Column, ForeignKey } from 'sequelize-typescript';
import * as Models from '@sudonym/models';
import { BaseModel } from '../base.model';
import { Contact } from 'module/contact/contact.model';

@Table({
	scopes: ContactAddress.scopes,
})
export class ContactAddress extends BaseModel implements Models.ContactAddress {
	@ForeignKey(() => Contact)
	@Column
	contactId: number;

	@Column
	addressType: string;

	@Column
	address: string;

	@Column
	name: string;

	static scopes = {};
}
