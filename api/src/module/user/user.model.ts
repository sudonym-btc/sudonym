import * as Models from '@sudonym/models';
import { LIGHTNINGADDRESSREGEX } from '@sudonym/models';
import { ValidationError, ValidationErrorItem } from 'sequelize';
import {
	Column,
	HasMany,
	PrimaryKey,
	Table,
	Validate
} from 'sequelize-typescript';
import { BaseModel } from '../base.model';
import { Sender } from '../sender/sender.model';

@Table
export class User extends BaseModel implements Models.User {
	@PrimaryKey
	@Column
	id: string;

	@Column
	firebaseId: string;

	@Validate({
		is: new RegExp(LIGHTNINGADDRESSREGEX),
		unique: async (val) => {
			if (
				await User.findOne({
					where: {
						lightningAddress: val,
					},
				})
			)
				throw new ValidationError('unique', [
					new ValidationErrorItem(
						'',
						'unique violation',
						'lightningAddress',
						val,
						this,
						'',
						'',
						[]
					),
				]);
		},
	})
	@Column
	lightningAddress: string;

	@HasMany(() => Sender)
	Senders: Sender[];

	static accessors = {
		canFind: (id) => [{ id }],
	};
}
