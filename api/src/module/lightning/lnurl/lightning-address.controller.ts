import { Controller, Get, Inject, Param, Query } from '@nestjs/common';
import { Op, Sequelize } from 'sequelize';
import { PotUser } from 'module/pot-user/pot-user.model';
import { Pot } from 'module/pot/pot.model';
import { User } from 'module/user/user.model';

import { LnUrlService } from './lnurl.service';

@Controller('')
export class LightningAddressController {
	@Inject(LnUrlService) lnUrlService: LnUrlService;

	@Get('.well-known/lnurlp/:user')
	async lightningAddress(@Param('user') lightningAddress) {
		let indexOfLastStop = lightningAddress.lastIndexOf('.');
		indexOfLastStop =
			indexOfLastStop >= 0 ? indexOfLastStop : lightningAddress.length;
		const user = await User.findOne({
			where: {
				lightningAddress: lightningAddress.substring(
					0,
					indexOfLastStop
				),
			},
		});

		let potName = null;
		if (indexOfLastStop != lightningAddress.length) {
			potName = lightningAddress.substring(
				indexOfLastStop + 1,
				lightningAddress.length
			);
		}
		const pot = await Pot.findOne({
			where: {
				id: {
					[Op.in]: (
						await PotUser.findAll({
							where: {
								userId: user.id,
							},
						})
					).map((i) => i.potId),
				},
			},
			order: potName
				? [
						[
							Sequelize.literal(`
                name="${potName}"`),
							'DESC',
						],
				  ]
				: [],
		});

		return (await this.lnUrlService.createPayRequest(pot.id)).params;
	}
}
