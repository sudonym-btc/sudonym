import {
	Table,
	Column,
	Model,
	HasMany,
	PrimaryKey,
	AutoIncrement,
	Sequelize,
} from 'sequelize-typescript';
import { DataTypes } from 'sequelize';
import { BaseModel } from '../../../module/base.model';

@Table
export class LnUrl extends BaseModel {
	@PrimaryKey
	@Column
	id: string;
	@Column potId: number;
	@Column tag: string;
	@Column(DataTypes.JSON) params: object;
}
