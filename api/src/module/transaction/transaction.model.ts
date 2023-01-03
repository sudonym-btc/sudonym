import { HttpException } from '@nestjs/common';
import * as Models from '@sudonym/models';
import { authUserIdGetter } from 'helper/context-request';
import { BillSplit } from 'module/bill-split/bill-split.model';
import { BoltCard } from 'module/bolt-card/bolt-card.model';
import { ContactAddress } from 'module/contact-address/contact-address.model';
import { Contact } from 'module/contact/contact.model';
import { PotUser } from 'module/pot-user/pot-user.model';
import { Pot } from 'module/pot/pot.model';
import { Receiver } from 'module/receiver/receiver.model';
import { Sender } from 'module/sender/sender.model';
import { User } from 'module/user/user.model';
import { DataTypes } from 'sequelize';
import {
	AllowNull,
	AutoIncrement,
	BeforeCreate,
	BelongsTo,
	Column,
	CreatedAt,
	DataType,
	Default,
	ForeignKey,
	HasOne,
	PrimaryKey,
	Table,
} from 'sequelize-typescript';
import { BaseModel } from '../base.model';
import { Invoice } from './invoice.model';
import { Onchain } from './onchain.model';
const { Op } = require('sequelize');

@Table({
	scopes: Transaction.scopes,
	paranoid: true,
})
export class Transaction extends BaseModel implements Models.Transaction {
	@AutoIncrement
	@PrimaryKey
	@AllowNull(false)
	@Column
	id: number;

	@ForeignKey(() => Onchain)
	@AllowNull(true)
	@Column(DataType.STRING(1024))
	onchainId: string;

	@ForeignKey(() => Invoice)
	@AllowNull(true)
	@Column(DataType.STRING(1024))
	invoiceId: string;

	@Column(DataType.STRING(1024))
	txid: string;

	@Column
	type: string;

	@Column(DataTypes.TEXT('medium'))
	description: string;

	@Column(DataType.STRING(1024))
	address: string;

	@Column(DataType.STRING(1024))
	originalAddress: string;

	@Default(null)
	@Column
	status: boolean;

	@Column(DataType.STRING(1024))
	errorMessage: string;

	@ForeignKey(() => Transaction)
	@AllowNull(true)
	@Column
	transactionId: number;

	@BelongsTo(() => ContactAddress)
	ContactAddress: ContactAddress;

	@ForeignKey(() => ContactAddress)
	@AllowNull(true)
	@Column
	contactAddressId: number;

	// @BelongsTo(() => BillSplit)
	// BillSplit: BillSplit;

	@ForeignKey(() => BillSplit)
	@AllowNull(true)
	@Column
	billSplitId: number;

	@BelongsTo(() => User)
	User: User;

	@ForeignKey(() => User)
	@AllowNull(true)
	@Column
	userId: string;

	@HasOne(() => BillSplit)
	BillSplit: BillSplit;

	@BelongsTo(() => Pot)
	Pot: Pot;

	@ForeignKey(() => Pot)
	@Column
	potId: number;

	@BelongsTo(() => Sender)
	Sender: Sender;

	@ForeignKey(() => Sender)
	@AllowNull(true)
	@Column
	senderId: number;

	@BelongsTo(() => Receiver)
	Receiver: Receiver;

	@ForeignKey(() => Receiver)
	@AllowNull(true)
	@Column
	receiverId: number;

	@AllowNull(false)
	@Column(DataType.DOUBLE(21, 11))
	amount: number;

	@AllowNull(true)
	@Column(DataType.DOUBLE(21, 11))
	totalAmount: number;

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

	@BeforeCreate
	static canOnlyCreateTransactionsFromOwnPot = async (params) => {
		if (
			authUserIdGetter() &&
			!(await Pot.accessors.canFind(params.potId))
				.map((i) => i.id)
				.includes(authUserIdGetter())
		) {
			throw new HttpException('Cannot create this transaction', 403);
		}
	};

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

	static scopes = {
		findOne: () => ({
			include: [
				{
					model: Pot,
					as: 'Pot',
				},
			],
		}),
		find: () => ({
			include: [
				{
					model: ContactAddress,
					as: 'ContactAddress',
					include: [
						{
							model: Contact,
							as: 'Contact',
						},
					],
				},
				{
					model: Sender,
					as: 'Sender',
					include: [
						{
							model: BoltCard,
							as: 'BoltCard',
						},
					],
				},
				{
					model: Receiver,
					as: 'Receiver',
				},
			],
		}),
	};
}

export const roundToDisplay = (amount: number, currency: string) =>
	currency == 'BTC'
		? parseFloat(amount.toFixed(8))
		: parseFloat(amount.toFixed(2));
