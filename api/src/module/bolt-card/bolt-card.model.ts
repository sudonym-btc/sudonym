import * as Models from '@sudonym/models';
import { context } from 'helper/context-request';
import { Sender } from 'module/sender/sender.model';
import { User } from 'module/user/user.model';
import {
	AutoIncrement,
	BeforeCreate,
	BelongsTo,
	Column,
	ForeignKey,
	PrimaryKey,
	Table,
} from 'sequelize-typescript';
import { BaseModel } from '../base.model';

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
		params.userId = context.get('request')?.auth?.uid;
	}

	@BelongsTo(() => Sender)
	Sender: Sender;

	@ForeignKey(() => Sender)
	@Column
	senderId: number;

	@Column
	name: string;

	@Column
	written: number;

	static accessors = {
		canFind: (id) =>
			BoltCard.findAll({
				attributes: [['userId', 'id']],
				raw: true,
				where: {
					id,
				},
			}),
	};

	static scopes = {
		find: () => ({
			include: [
				{
					model: Sender,
					required: true,
					as: 'Sender',
					include: [
						{
							required: true,
							model: User,
							as: 'User',
							where: context.get('request')?.auth?.uid
								? {
										id: context.get('request')?.auth.uid,
								  }
								: {},
						},
					],
				},
			],
		}),
	};
}
