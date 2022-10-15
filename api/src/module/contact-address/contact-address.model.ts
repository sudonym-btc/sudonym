import { Table, Column, ForeignKey, PrimaryKey, AutoIncrement, AllowNull, BelongsTo, HasOne, HasMany } from 'sequelize-typescript';
import * as Models from '@sudonym/models';
import { BaseModel } from '../base.model';
import { Contact } from '../contact/contact.model';
import { Transaction } from 'module/transaction/transaction.model';

@Table({
	scopes: ContactAddress.scopes,
})
export class ContactAddress extends BaseModel implements Models.ContactAddress {
	@PrimaryKey
	@AutoIncrement
	@Column
	id: number;

	@HasMany(() => Transaction)
	Transaction: Transaction;

	@BelongsTo(() => Contact)
	Contact: Contact;

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
