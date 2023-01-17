import * as Models from '@sudonym/models';
import { CurrencyCode } from '@sudonym/models';
import { authUserIdGetter, context } from 'helper/context-request';
import { BillSplit } from 'module/bill-split/bill-split.model';
import { Receiver } from 'module/receiver/receiver.model';
import { Sender } from 'module/sender/sender.model';
import { Transaction } from 'module/transaction/transaction.model';
import { FindOptions, ValidationError, ValidationErrorItem } from 'sequelize';
import {
	AfterCreate,
	AllowNull,
	AutoIncrement,
	Column,
	DataType,
	Default,
	HasMany,
	HasOne,
	PrimaryKey,
	Table,
	Validate,
} from 'sequelize-typescript';
import { BaseModel } from '../base.model';
import { PotUser } from '../pot-user/pot-user.model';

@Table({
	scopes: Pot.scopes,
	paranoid: true,
})
export class Pot extends BaseModel implements Models.Pot {
	@PrimaryKey
	@AutoIncrement
	@Column
	id: number;

	@Validate({
		unique: async (val) => {
			if (
				await Pot.findOne({
					include: [
						{
							model: PotUser,
							as: 'PotUser',
							where: {
								userId: authUserIdGetter() || val.userId,
							},
							required: true,
						},
					],
					where: {
						name: val,
					},
				})
			)
				throw new ValidationError('unique', [
					new ValidationErrorItem(
						'',
						'unique violation',
						'name',
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

	@HasOne(() => PotUser)
	PotUser: PotUser;

	@HasMany(() => PotUser)
	PotUsers: PotUser[];

	@HasMany(() => BillSplit)
	BillSplits: BillSplit[];

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
				userId: authUserIdGetter(),
			},
			order: [['index', 'DESC']],
		});
		await PotUser.create({
			potId: entity.id,
			index: prev ? prev.index + 1 : 1,
			userId: authUserIdGetter(),
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
		orderByIndex: () =>
			({
				order: [[{ model: PotUser, as: 'PotUser' }, 'index', 'asc']],
			} as FindOptions),
		find: () => ({
			...(context.get('request')?.auth
				? {
						include: [
							{
								model: PotUser,
								as: 'PotUser',
								required: true,
								where: {
									userId: context.get('request')?.auth?.uid,
								},
							},
						],
						...Pot.scopes.orderByIndex(),
				  }
				: {}),
		}),
	};
}
