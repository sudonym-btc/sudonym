import * as Models from '@sudonym/models';
import { BaseModel } from 'module/base.model';
import { Column, DataType, Table } from 'sequelize-typescript';

@Table
export class Offer extends BaseModel implements Models.Offer {
	@Column
	id: string;

	@Column
	potId: number;

	@Column
	active: boolean;

	@Column(DataType.DOUBLE(21, 11))
	amount: number | null;

	@Column
	bolt12: string;

	@Column
	bolt12Unsigned: string;
}
