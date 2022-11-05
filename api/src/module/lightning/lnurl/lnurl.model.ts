import Models, { PaymentRequest, WithdrawRequest } from '@sudonym/models';
import { DataTypes } from 'sequelize';
import { Column, PrimaryKey, Table } from 'sequelize-typescript';
import { BaseModel } from '../../../module/base.model';

@Table
export class LnUrl extends BaseModel implements Models.Lnurl {
	@PrimaryKey
	@Column
	id: string;

	@Column(DataTypes.JSON) params: WithdrawRequest | PaymentRequest;
}
