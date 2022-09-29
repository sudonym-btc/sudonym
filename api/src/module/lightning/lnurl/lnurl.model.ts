import { Table, Column, PrimaryKey } from 'sequelize-typescript';
import { DataTypes } from 'sequelize';
import { BaseModel } from '../../../module/base.model';
import { WithdrawRequest } from '@sudonym/models';
import { PaymentRequest } from '@sudonym/models';

@Table
export class LnUrl extends BaseModel {
	@PrimaryKey
	@Column
	id: string;
	@Column(DataTypes.JSON) params: PaymentRequest | WithdrawRequest;
}
