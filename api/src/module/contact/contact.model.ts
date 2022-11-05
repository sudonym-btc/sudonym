import * as Models from '@sudonym/models';
import { authUserIdGetter, context } from 'helper/context-request';
import {
	AllowNull,
	AutoIncrement,
	BeforeValidate,
	Column,
	ForeignKey,
	HasMany,
	PrimaryKey,
	Table,
} from 'sequelize-typescript';
import { BaseModel } from '../base.model';
import { ContactAddress } from '../contact-address/contact-address.model';
import { User } from '../user/user.model';

@Table({
	scopes: Contact.scopes,
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
		unique: 'composite',
	})
	userId: string;

	@AllowNull(false)
	@Column({
		unique: 'composite',
	})
	name: string;

	@HasMany(() => ContactAddress)
	ContactAddresses: Models.ContactAddress[];

	static accessors = {
		canFind: (id) =>
			Contact.findAll({
				attributes: [['userId', 'id']],
				raw: true,
				where: {
					id,
				},
			}),
	};

	static scopes = {
		find: () => ({
			...(context.get('request')?.auth
				? {
						where: {
							userId: context.get('request').auth.uid,
						},
				  }
				: {}),
			include: [
				{
					model: ContactAddress,
					as: 'ContactAddresses',
				},
			],
		}),
	};
}
