import { Table, Column, PrimaryKey, BelongsTo } from 'sequelize-typescript';
import { DataTypes } from 'sequelize';
import { BaseModel } from '../../../module/base.model';
import Models from '@sudonym/models';
import { WithdrawRequest } from '@sudonym/models';
import { PaymentRequest } from '@sudonym/models';
import { Sender } from '../../sender/sender.model';

@Table
export class LnUrl extends BaseModel implements Models.Lnurl {

	@PrimaryKey
	@Column
	id: string;

	@Column(DataTypes.JSON) params: WithdrawRequest | PaymentRequest;

	@BelongsTo(() => Sender)
	Sender: Sender;

}
