import {
	Table,
	Column,
	Model,
	HasMany,
	PrimaryKey,
	AutoIncrement,
	Sequelize,
	BeforeCreate,
	AfterCreate,
	Default,
	NotNull,
	AllowNull,
	DataType,
} from 'sequelize-typescript';
import * as Models from '@sudonym/models';
import { CurrencyCode } from '@sudonym/models';
import { PotUser } from '../pot-user/pot-user.model';
import { RequestType } from 'helper/parse-request.decorator';
import { BaseModel } from '../base.model';
import { requestContextCls } from 'helper/context-request';
import { User } from 'module/user/user.model';
import { Transaction } from 'module/transaction/transaction.model';
const { Op } = require('sequelize');

@Table({
	scopes: Pot.scopes,
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

	@AfterCreate
	static addPotUser = async (rec) => {
		await PotUser.create({
			potId: rec.id,
			userId: requestContextCls.get('request')?.auth.uid,
		});
	};

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
		find: (request: RequestType) =>
			request
				? {
						include: [
							{
								model: PotUser,
								as: 'PotUsers',
								required: true,
								where: {
									userId: request.auth.uid,
								},
							},
						],
				  }
				: {},
	};
}
