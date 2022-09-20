import { Table, Column, ForeignKey, PrimaryKey } from 'sequelize-typescript';
import * as Models from '@sudonym/models';
import { BaseModel } from '../base.model';
import { User } from 'module/user/user.model';
import { Sender } from 'module/sender/sender.model';

@Table({
	scopes: BoltCard.scopes,
})
export class BoltCard extends BaseModel implements Models.BoltCard {

	@PrimaryKey
	@Column
	id: number;

	@ForeignKey(() => User)
	@Column
	userId: string;

	@ForeignKey(() => Sender)
	@Column
	senderId: number;

	@Column
	name: string;

	@Column
	data: string;

	static scopes = {};
}
