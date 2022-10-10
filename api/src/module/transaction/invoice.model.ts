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
export class Invoice extends BaseModel implements Models.LightningTransaction {
	@Column
	id: string;

	@Column(DataType.DOUBLE(21, 11))
	amount: number | null;

	@Column
	preimage: string;

	@Column
	status: boolean;
}
