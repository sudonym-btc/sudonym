import {
	Controller,
	Get,
	HttpException,
	Inject,
	Param,
	Query,
} from '@nestjs/common';
import { Op, Sequelize } from 'sequelize';
import { PotUser } from 'module/pot-user/pot-user.model';
import { Pot } from 'module/pot/pot.model';
import { User } from 'module/user/user.model';

import { LnUrlService } from '../lnurl.service';
import { ReceiverService } from 'module/receiver/receiver.service';
import { PotService } from 'module/pot/pot.service';
import { MSATOSHIS, SATOSHIS } from '@sudonym/models';

@Controller('')
export class LightningAddressController {
	@Inject(LnUrlService) lnUrlService: LnUrlService;
	@Inject(PotService) potService: PotService;
	@Inject(ReceiverService) receiverService: ReceiverService;

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

		if (!user) {
			throw new HttpException(
				{ status: 'ERROR', reason: 'User does not exist' },
				400
			);
		}

		let potName = null;
		if (indexOfLastStop != lightningAddress.length) {
			potName = lightningAddress.substring(
				indexOfLastStop + 1,
				lightningAddress.length
			);
		}

		const pot = await this.potService.findForUser(user.id, null, potName);
		const receiver = await this.receiverService.create({
			potId: pot.id,
			type: 'lnurl',
			amount: 1 / SATOSHIS
		});

		return (await this.lnUrlService.findOne(receiver.lnurlId)).params;
	}
}
