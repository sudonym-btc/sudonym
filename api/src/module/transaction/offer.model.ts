import { Table, Column, Model, HasMany, CreatedAt } from 'sequelize-typescript';
import * as Models from '@sudonym/models';

@Table
export class Offer extends Model implements Models.Offer {
	@Column
	id: string;

	@Column
	potId: number;

	@Column
	active: boolean;

	@Column
	amount: number | null;

	@Column
	bolt12: string;

	@Column
	bolt12Unsigned: string;
}
