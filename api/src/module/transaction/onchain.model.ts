import {
	Table,
	Column,
	Model,
	HasMany,
	CreatedAt,
	DataType,
} from 'sequelize-typescript';
import * as Models from '@sudonym/models';
import { BaseModel } from 'module/base.model';

@Table
export class Onchain extends BaseModel implements Models.OnchainTransaction {
	@Column
	id: string;

	@Column(DataType.DOUBLE(18, 8))
	amount: number | null;

	@Column
	fromAddress: string;

	@Column
	toAddress: string;

	@Column
	blockHeight: number;
}
