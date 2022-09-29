import { Inject, Injectable } from '@nestjs/common';
import { BaseService } from '../base.service';
import { Pot } from './pot.model';
import { Op, Sequelize } from 'sequelize';
import { PotUser } from 'module/pot-user/pot-user.model';

@Injectable()
export class PotService extends BaseService(Pot) {
	async findForUser(userId, potId = null, potName = null) {
		if (potId) {
			return this.findOne(potId);
		} else {
			return this.findOne({
				include: [
					{
						required: true,
						model: PotUser,
						where: {
							userId,
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
