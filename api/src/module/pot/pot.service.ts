import { Injectable } from '@nestjs/common';
import { context } from 'helper/context-request';
import { PotUser } from 'module/pot-user/pot-user.model';
import { Sequelize } from 'sequelize';
import { BaseService } from '../base.service';
import { Pot } from './pot.model';

@Injectable()
export class PotService extends BaseService(Pot) {
	async findForUser(userId = null, potId = null, potName = null) {
		if (potId) {
			return this.findOne(potId);
		} else {
			return this.findOne({
				include: [
					{
						required: true,
						model: PotUser,
						where: {
							userId: userId || context.get('request')?.auth?.uid,
						},
					},
				],
				order: [
					...(potName
						? [
								[
									Sequelize.literal(`
                        id="${potId}"`),
									'DESC',
								],
						  ]
						: []),
					...(potName
						? [
								[
									Sequelize.literal(`
                    name="${potName}"`),
									'DESC',
								],
						  ]
						: []),
				],
			});
		}
	}
}
