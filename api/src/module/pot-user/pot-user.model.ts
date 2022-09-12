import {
	Table,
	Column,
	Model,
	HasMany,
	PrimaryKey,
	AutoIncrement,
	BelongsTo,
	ForeignKey,
} from 'sequelize-typescript';
import * as Models from '@sudonym/models';
import { BaseModel } from '../base.model';
import { Pot } from '../pot/pot.model';

@Table({
	scopes: PotUser.scopes,
})
export class PotUser extends BaseModel implements Models.PotUser {
	@PrimaryKey
	@AutoIncrement
	@Column
	id: number;

	@BelongsTo(() => Pot)
	Pot: Pot;

	@ForeignKey(() => Pot)
	@Column
	potId: number;

	@Column
	userId: number;
}
