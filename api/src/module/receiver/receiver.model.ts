import {
	Table,
	Column,
	Model,
	CreatedAt,
	PrimaryKey,
	DataType,
	AutoIncrement,
	Default,
	ForeignKey,
	AllowNull,
	IsNumeric,
	IsIn,
	IsInt,
	BelongsTo,
	Validate,
} from 'sequelize-typescript';
import * as Models from '@sudonym/models';
import {
	ADDRESS_TYPES,
	CurrencyCode,
	CurrencyCodes,
	TAddressType,
} from '@sudonym/models';
import { BaseModel } from '../base.model';
import { Pot } from 'module/pot/pot.model';
import { LnUrl } from 'module/lightning/lnurl/lnurl.model';
import { PotUser } from 'module/pot-user/pot-user.model';

@Table({
	scopes: Receiver.scopes,
})
export class Receiver extends BaseModel implements Models.Receiver {
	@PrimaryKey
	@AutoIncrement
	@Column
	id: number;

	@ForeignKey(() => Receiver)
	@Column
	parentId: number;

	@AllowNull(false)
	@Column(DataType.ENUM(...ADDRESS_TYPES))
	type: TAddressType;

	@BelongsTo(() => Pot)
	Pot: Pot;

	@ForeignKey(() => Pot)
	@Column
	potId: number;

	@ForeignKey(() => LnUrl)
	@Column
	lnurlId: string;

	@Column(DataType.STRING(1024))
	data: string;

	@AllowNull
	@Validate({
		isNumOrNull(val) {
			if (val && isNaN(val)) {
				throw 'Amount must be empty or a number';
			}
		},
	})
	@Column(DataType.DOUBLE(21, 11))
	amount: number;

	@IsIn([CurrencyCodes])
	@Default('BTC')
	@Column
	amountCurrency: CurrencyCode;

	@IsInt
	@Default(0)
	@Column
	received: number;

	@CreatedAt
	@Column
	createdAt: Date;

	static accessors = {
		canFind: (id) =>
			PotUser.findAll({
				attributes: [['userId', 'id']],
				raw: true,
				include: [
					{
						model: Pot,
						attributes: [],
						required: true,
						include: [
							{
								model: Receiver,
								required: true,
								attributes: [],
								where: {
									id,
								},
							},
						],
					},
				],
			}),
	};
}
