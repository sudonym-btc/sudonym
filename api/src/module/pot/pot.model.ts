import {
	Table,
	Column,
	Model,
	HasMany,
	PrimaryKey,
	AutoIncrement,
	Sequelize,
	BeforeCreate,
	AfterCreate,
} from 'sequelize-typescript';
import * as Models from '@sudonym/models';
import { CurrencyCode } from '@sudonym/models';
import { PotUser } from '../pot-user/pot-user.model';
import { RequestType } from 'src/helper/parse-request.decorator';
import { BaseModel } from '../base.model';
import { requestContextCls } from 'src/helper/context-request';

@Table({
	scopes: Pot.scopes,
})
export class Pot extends BaseModel implements Models.Pot {
	@PrimaryKey
	@AutoIncrement
	@Column
	id: number;

	@Column
	name: string;

	@Column
	balance: number;

	@Column
	spendableBalance: number;

	@Column
	currency: CurrencyCode;

	@HasMany(() => PotUser)
	PotUsers: PotUser[];

	@AfterCreate
	static addPotUser = async (rec) => {
		await PotUser.create({
			potId: rec.id,
			userId: requestContextCls.get('request')?.auth.uid,
		});
	};

	static scopes = {
		find: (request: RequestType) =>
			request
				? {
						include: [
							{
								model: PotUser,
								as: 'PotUsers',
								required: true,
								where: {
									UserId: request.auth.uid,
								},
							},
						],
				  }
				: {},
	};
}
