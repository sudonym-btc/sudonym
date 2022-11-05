import * as Models from '@sudonym/models';
import { Column, Table } from 'sequelize-typescript';
import { BaseModel } from '../base.model';

@Table
export class UserDevice extends BaseModel implements Models.UserDevice {
	@Column
	uid: string;

	@Column({
		unique: true,
	})
	token: string;
}
