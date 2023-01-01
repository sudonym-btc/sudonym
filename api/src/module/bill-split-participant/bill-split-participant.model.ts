import { HttpException } from '@nestjs/common';
import * as Models from '@sudonym/models';
import { BillSplit } from 'module/bill-split/bill-split.model';
import { PotUser } from 'module/pot-user/pot-user.model';
import { Pot } from 'module/pot/pot.model';
import { Receiver } from 'module/receiver/receiver.model';
import { Transaction } from 'module/transaction/transaction.model';
import {
	AllowNull,
	AutoIncrement,
	BelongsTo,
	Column,
	DataType,
	Default,
	ForeignKey,
	PrimaryKey,
	Table,
	Validate,
} from 'sequelize-typescript';
import { BaseModel } from '../base.model';

@Table({
	scopes: BillSplitParticipant.scopes,
	paranoid: true,
})
export class BillSplitParticipant
	extends BaseModel
	implements Models.BillSplitParticipant
{
	@PrimaryKey
	@AutoIncrement
	@Column
	id: number;

	@BelongsTo(() => BillSplit)
	BillSplit: BillSplit;

	@AllowNull(false)
	@ForeignKey(() => BillSplit)
	@Column
	billSplitId: number;

	@AllowNull(false)
	@Validate({
		greaterThanZero(val) {
			if (val <= 0)
				throw new HttpException('Must be greater than zero', 400);
		},
	})
	@Column(DataType.DOUBLE(21, 11))
	amount: number;

	@AllowNull(false)
	@Default(0)
	@Column(DataType.DOUBLE(21, 11))
	amountPaid: number;

	@AllowNull(false)
	@Default(false)
	@Column
	paid: boolean;

	static accessors = {
		canFind: (id) =>
			PotUser.findAll({
				attributes: [['userId', 'id']],
				raw: true,
				include: [
					{
						model: Pot,
						as: 'Pot',
						required: true,
						include: [
							{
								model: Transaction,
								as: 'Transactions',
								required: true,
								include: [
									{
										model: Receiver,
										as: 'Receiver',
										required: true,
										where: {
											billSplitParticipantId: id,
										},
									},
								],
							},
						],
					},
				],
			}),
	};

	static scopes = {};
}
