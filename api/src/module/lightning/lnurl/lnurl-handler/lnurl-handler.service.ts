import { Inject } from '@nestjs/common';
import { ReceiveService } from 'module/receive/receive.service';
import { LnUrlService } from '../lnurl.service';
import { MSATOSHIS } from '@sudonym/models';

export class LnUrlHandlerService {
	@Inject(LnUrlService) lnUrlService: LnUrlService;
	@Inject(ReceiveService) receiveService: ReceiveService;

	async handle(id, amount) {
		const tag = await this.lnUrlService.findOne(id);
		const receiver = await this.receiveService.getInvoice(
			{
				potId: tag.potId,
				type: 'bolt11',
				amount: amount / MSATOSHIS,
				amountCurrency: "BTC"
			}
		);
		return {
			pr: receiver.data,
			routes: [],
		};
	}
}
