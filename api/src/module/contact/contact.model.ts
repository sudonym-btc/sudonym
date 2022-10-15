import {
	Table,
	Column,
	PrimaryKey,
	AutoIncrement,
	ForeignKey,
	HasMany,
	BeforeCreate,
	AllowNull,
	BeforeValidate,
} from 'sequelize-typescript';
import * as Models from '@sudonym/models';
import { BaseModel } from '../base.model';
import { User } from '../user/user.model';
import { ContactAddress } from '../contact-address/contact-address.model';
import { authUserIdGetter, context } from 'helper/context-request';

@Table({
	scopes: Contact.scopes
})
export class Contact extends BaseModel implements Models.Contact {
	@PrimaryKey
	@AutoIncrement
	@Column
	id: number;

	@BeforeValidate
	static populateUserId(params) {
		if (authUserIdGetter()) {
			params.userId = authUserIdGetter();
		}
	}

	@AllowNull(false)
	@ForeignKey(() => User)
	@Column({
		unique: 'composite'
	})
	userId: string;

	@AllowNull(false)
	@Column({
		unique: 'composite'
	})
	name: string;

	@HasMany(() => ContactAddress)
	ContactAddresses: Models.ContactAddress[];

	static scopes = {
		find: () => ({
			include: [{
				model: ContactAddress,
				as: 'ContactAddresses'
			}]
		})
	};
}
