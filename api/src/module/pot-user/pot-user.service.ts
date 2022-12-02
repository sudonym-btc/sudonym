import { Injectable } from '@nestjs/common';
import { context } from 'helper/context-request';
import { BaseService } from 'module/base.service';
import { Op } from 'sequelize';
import { PotUser } from './pot-user.model';

@Injectable()
export class PotUserService extends BaseService(PotUser) {
	onModuleInit() {
		this.afterDelete.hook(async (rec) => {
			// shift all pots greater than the deleted on down by one
			for (const potUser of await PotUser.findAll({
				where: {
					userId: rec.entity.userId,
					index: {
						[Op.gt]: rec.entity.index,
					},
				},
			})) {
				await this.update(potUser.id, { index: potUser.index - 1 });
			}
		});

		this.afterUpdate.hook(async (rec) => {
			await context.runAndReturn(async () => {
				if (context.get('updatingIndexes')) return;
				else {
					context.set('updatingIndexes', true);
					if (!rec.entity.changed('index')) return;
					const movingForward =
						rec.entity.index < rec.entity.previous('index');

					// shift all pots greater than the deleted on down by one
					for (const potUser of await PotUser.findAll({
						where: {
							id: {
								[Op.ne]: rec.entity.id,
							},
							userId: rec.entity.userId,
							index: movingForward
								? {
										[Op.gte]: rec.entity.index,
										[Op.lt]: rec.entity.previous('index'),
								  }
								: {
										[Op.lte]: rec.entity.index,
										[Op.gt]: rec.entity.previous('index'),
								  },
						},
					})) {
						await this.update(potUser.id, {
							index: potUser.index + (movingForward ? 1 : -1),
						});
					}
				}
			});
		});
	}
}
