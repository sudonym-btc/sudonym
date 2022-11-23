import * as Models from '@sudonym/models';
import { CurrencyCode } from '@sudonym/models';
import { context } from 'helper/context-request';
import { Receiver } from 'module/receiver/receiver.model';
import { Sender } from 'module/sender/sender.model';
import { Transaction } from 'module/transaction/transaction.model';
import {
	AfterCreate,
	AllowNull,
	AutoIncrement,
	Column,
	DataType,
	Default,
	HasMany,
	PrimaryKey,
	Table,
} from 'sequelize-typescript';
import { BaseModel } from '../base.model';
import { PotUser } from '../pot-user/pot-user.model';
const { Op } = require('sequelize');

@Table({
	scopes: Pot.scopes,
	paranoid: true,
})
export class Pot extends BaseModel implements Models.Pot {
	@PrimaryKey
	@AutoIncrement
	@Column
	id: number;

	@Column
	name: string;

	@AllowNull(false)
	@Default(0)
	@Column(DataType.DOUBLE(21, 11))
	balance: number;

	@AllowNull(false)
	@Default(0)
	@Column(DataType.DOUBLE(21, 11))
	spendableBalance: number;

	@Column
	currency: CurrencyCode;

	@HasMany(() => PotUser)
	PotUsers: PotUser[];

	@HasMany(() => Transaction)
	Transactions: Transaction[];

	@HasMany(() => Receiver)
	Receivers: Receiver[];

	@HasMany(() => Sender)
	Senders: Sender[];

	// Must be here as used in create hook

	@AfterCreate
	static async potUserCreator(entity) {
		const prev = await PotUser.findOne({
			where: {
				userId: context.get('request')?.auth.uid,
			},
			order: [['index', 'DESC']],
		});
		await PotUser.create({
			potId: entity.id,
			index: prev ? prev.index + 1 : 1,
			userId: context.get('request')?.auth.uid,
		});
	}

	static accessors = {
		canFind: (id) =>
			PotUser.findAll({
				attributes: [['userId', 'id']],
				raw: true,
				where: {
					potId: id,
				},
			}),
	};

	static scopes = {
		find: () =>
			context.get('request')?.auth
				? {
						include: [
							{
								model: PotUser,
								as: 'PotUsers',
								required: true,
								where: {
									userId: context.get('request').auth.uid,
								},
							},
						],
				  }
				: {},
	};
}
