import { Table, Column, ForeignKey, PrimaryKey, AutoIncrement, AllowNull } from 'sequelize-typescript';
import * as Models from '@sudonym/models';
import { BaseModel } from '../base.model';
import { Contact } from 'module/contact/contact.model';

@Table({
	scopes: ContactAddress.scopes,
})
export class ContactAddress extends BaseModel implements Models.ContactAddress {
	@PrimaryKey
	@AutoIncrement
	@Column
	id: number;

	@AllowNull(false)
	@ForeignKey(() => Contact)
	@Column({
		unique: 'composite'
	})
	contactId: number;

	@Column
	addressType: string;

	@Column({
		unique: 'composite'
	})
	address: string;

	@Column
	name: string;

	static scopes = {};
}
