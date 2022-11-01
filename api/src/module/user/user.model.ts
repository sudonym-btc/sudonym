import {
	Table,
	Column,
	Model,
	HasMany,
	PrimaryKey,
	AutoIncrement,
	Validate,
} from 'sequelize-typescript';
import * as Models from '@sudonym/models';
import { BaseModel } from '../base.model';
import { Sender } from '../sender/sender.model';
import { ValidationError, ValidationErrorItem } from 'sequelize';

@Table
export class User extends BaseModel implements Models.User {
	@PrimaryKey
	@Column
	id: string;

	@Column
	firebaseId: string;

	@Validate({
		unique: async (val) => {
			if(await User.findOne({
				where: {
					lightningAddress: val
				}
			})) 
				throw new ValidationError('unique', [new ValidationErrorItem('', 'unique violation', 'lightningAddress', val, this, '', '', [])])
		}
	})
	@Column
	lightningAddress: string;

	@HasMany(() => Sender)
	Senders: Sender[];

	static accessors = {
		canFind: (id) => [{id}]
	}
}
