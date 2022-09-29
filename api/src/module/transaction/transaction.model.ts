import {
	Table,
	Column,
	CreatedAt,
	PrimaryKey,
	Default,
	AutoIncrement,
	AllowNull,
	DataType,
	ForeignKey,
	Sequelize,
	BelongsTo,
} from 'sequelize-typescript';
import * as Models from '@sudonym/models';
import { BaseModel } from '../base.model';
import { Receiver } from 'module/receiver/receiver.model';
import { Sender } from 'module/sender/sender.model';
import { Onchain } from './onchain.model';
import { Invoice } from './invoice.model';
import { User } from 'module/user/user.model';
import { Pot } from 'module/pot/pot.model';
import { PotUser } from 'module/pot-user/pot-user.model';
const { Op } = require('sequelize');

@Table({
	scopes: Transaction.scopes,
})
export class Transaction extends BaseModel implements Models.Transaction {
	@AutoIncrement
	@PrimaryKey
	@AllowNull(false)
	@Column
	id: number;

	@ForeignKey(() => Onchain)
	@Column(DataType.STRING(1024))
	onchainId: string;

	@ForeignKey(() => Invoice)
	@Column(DataType.STRING(1024))
	invoiceId: string;

	@Column(DataType.STRING(1024))
	txid: string;

	@Column
	type: string;

	@Column
	description: string;

	@Column(DataType.STRING(1024))
	address: string;

	@Column(DataType.STRING(1024))
	originalAddress: string;

	@Default(null)
	@Column
	status: boolean;

	@ForeignKey(() => Transaction)
	@Column
	transactionId: number;

	@BelongsTo(() => Pot)
	Pot: Pot;

	@ForeignKey(() => Pot)
	@Column
	potId: number;

	@ForeignKey(() => Sender)
	@Column
	senderId: number;

	@ForeignKey(() => Receiver)
	@Column
	receiverId: number;

	@AllowNull(false)
	@Column(DataType.DOUBLE(18, 8))
	amount: number;

	@AllowNull(false)
	@Column
	outgoing: boolean;

	@AllowNull(false)
	@Default('BTC')
	@Column
	currencyCode: string;

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
								model: Transaction,
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
