import { Table, Column, PrimaryKey, BelongsTo } from 'sequelize-typescript';
import { DataTypes } from 'sequelize';
import { BaseModel } from '../../../module/base.model';
import { WithdrawRequest } from '@sudonym/models';
import { PaymentRequest } from '@sudonym/models';
import { Sender } from '../../sender/sender.model';

@Table
export class LnUrl extends BaseModel {
	@PrimaryKey
	@Column
	id: string;
	@Column(DataTypes.JSON) params: PaymentRequest | WithdrawRequest;

	@BelongsTo(() => Sender)
	Sender: Sender;
}
