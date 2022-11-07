import { Controller, Get, HttpException, Inject, Param } from '@nestjs/common';
import { User } from 'module/user/user.model';

import { SATOSHIS } from '@sudonym/models';
import { PotService } from 'module/pot/pot.service';
import { ReceiverService } from 'module/receiver/receiver.service';
import { LnUrlHandlerService } from '../lnurl-handler/lnurl-handler.service';
import { LnUrlService } from '../lnurl.service';

@Controller('')
export class LightningAddressController {
	@Inject(LnUrlService) lnUrlService: LnUrlService;
	@Inject(LnUrlHandlerService) lnUrlHandlerService: LnUrlHandlerService;
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
			amount: 1 / SATOSHIS,
		});

		return await this.lnUrlHandlerService.serve(receiver.lnurlId);
	}
}
