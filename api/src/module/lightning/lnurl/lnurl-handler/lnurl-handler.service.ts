import { HttpException, Inject } from '@nestjs/common';
import { ReceiverService } from 'module/receiver/receiver.service';
import { LnUrlService } from '../lnurl.service';
import { MSATOSHIS } from '@sudonym/models';
import { TransactionService } from 'module/transaction/transaction.service';
import { SenderService } from 'module/sender/sender.service';
import { getAddressType } from 'module/action/action.service';
import * as bolt11 from 'bolt11';
import { PotService } from 'module/pot/pot.service';

export class LnUrlHandlerService {
	@Inject(LnUrlService) lnUrlService: LnUrlService;
	@Inject(ReceiverService) receiveService: ReceiverService;
	@Inject(PotService) potService: PotService;
	@Inject(SenderService) senderService: SenderService;
	@Inject(TransactionService) transactionService: TransactionService;

	// Function that is called when someone else triggers OUR callbacks.
	async handle(id, query) {
		const tag = await this.lnUrlService.findOne(id);
		switch (tag.params.tag) {
			case 'payRequest':
				let parentReceiver = await this.receiveService.findOne({
					where: {
						lnurlId: tag.id,
					},
				});

				// Create a new receiver, this time bolt11 not lnurl
				const receiver = await this.receiveService.getInvoice({
					parentId: parentReceiver.id,
					potId: parentReceiver.potId,
					type: 'bolt11',
					amount: query.amount / MSATOSHIS,
					amountCurrency: 'BTC',
				});
				return {
					disposable: false,
					pr: receiver.data,
					routes: [],
				};
			case 'withdrawRequest':
				const sender = await this.senderService.findOne({
					where: {
						lnurlId: tag.id,
					},
				});
				console.log(sender);
				const parsed = bolt11.decode(query.pr);

				const pot = await this.potService.findForUser(
					sender.userId,
					sender.potId
				);
				console.log(pot);
				await this.transactionService.create({
					outgoing: true,
					potId: pot.id,
					senderId: sender.id,
					address: query.pr,
					originalAddress: query.pr,
					txid: query.pr,
					type: getAddressType(query.pr),
					amount: parseInt(parsed.millisatoshis) / MSATOSHIS,
					currencyCode: 'BTC',
				});
		}

		throw new HttpException('Unhandleable lnurl request', 400);
	}
}
