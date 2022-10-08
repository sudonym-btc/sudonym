import {
	Table,
	Column,
	PrimaryKey,
	AutoIncrement,
	ForeignKey,
	HasMany,
} from 'sequelize-typescript';
import * as Models from '@sudonym/models';
import { BaseModel } from '../base.model';
import { User } from 'module/user/user.model';
import { ContactAddress } from 'module/contact-address/contact-address.model';

@Table({
	scopes: Contact.scopes,
})
export class Contact extends BaseModel implements Models.Contact {
	@PrimaryKey
	@AutoIncrement
	@Column
	id: number;

	@ForeignKey(() => User)
	@Column
	userId: string;

	@Column
	name: string;

	@HasMany(() => ContactAddress)
	ContactAddresses: Models.ContactAddress[];

	static scopes = {};
}
