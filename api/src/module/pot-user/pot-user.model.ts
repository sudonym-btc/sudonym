import * as Models from '@sudonym/models';
import { User } from 'module/user/user.model';
import {
	AutoIncrement,
	BelongsTo,
	Column,
	ForeignKey,
	PrimaryKey,
	Table,
} from 'sequelize-typescript';
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

	@ForeignKey(() => User)
	@Column
	userId: string;
}
