import { Inject, Injectable } from '@nestjs/common';
import { context } from 'helper/context-request';
import { PotUser } from 'module/pot-user/pot-user.model';
import { PotUserService } from 'module/pot-user/pot-user.service';
import { Sequelize } from 'sequelize';
import { BaseService } from '../base.service';
import { Pot } from './pot.model';

@Injectable()
export class PotService extends BaseService(Pot) {
	@Inject(PotUserService) potUserService: PotUserService;

	onModuleInit() {
		this.afterDelete.hook(async (rec) => {
			const potUsers = await PotUser.findAll({
				where: {
					potId: rec.entity.id,
				},
			});
			for (const potUser of potUsers) {
				await this.potUserService.delete(potUser.id);
			}
		});
	}
	async findForUser(userId = null, potId = null, potName = null) {
		if (potId) {
			return this.findOne(potId);
		} else {
			const order = Pot.scopes.orderByIndex().order;
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
                    name="${potName}"`),
									'DESC',
								],
						  ]
						: []),
					...(order instanceof Array ? order : []),
				],
			});
		}
	}
}
