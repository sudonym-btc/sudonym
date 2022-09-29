import {
	Table,
	Column,
	ForeignKey,
	PrimaryKey,
	HasOne,
	BelongsTo,
	AutoIncrement,
	BeforeCreate,
} from 'sequelize-typescript';
import * as Models from '@sudonym/models';
import { BaseModel } from '../base.model';
import { User } from 'module/user/user.model';
import { Sender } from 'module/sender/sender.model';
import { requestContextCls } from 'helper/context-request';

@Table({
	scopes: BoltCard.scopes,
})
export class BoltCard extends BaseModel implements Models.BoltCard {
	@PrimaryKey
	@AutoIncrement
	@Column
	id: number;

	@ForeignKey(() => User)
	@Column
	userId: string;

	@BeforeCreate
	static populateUserId(params) {
		params.userId = requestContextCls.get('request')?.auth?.uid;
	}

	@ForeignKey(() => Sender)
	@Column
	senderId: number;

	@BelongsTo(() => Sender)
	sender: Sender;

	@Column
	name: string;

	@Column
	written: number;

	static scopes = {
		find: () => ({
			include: [
				{
					model: Sender,
					as: 'sender',
				},
			],
		}),
	};
}
