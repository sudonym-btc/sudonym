import { HttpException, Inject, Logger } from '@nestjs/common';
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
	private readonly logger = new Logger(this.constructor.name);

	// Function that is called when someone else triggers OUR callbacks.
	async handle(id, query) {
		this.logger.warn("handling lnurl", id, query);
		const tag = await this.lnUrlService.findOne(id);
		switch (tag.params.tag) {
			case 'payRequest':
				let parentReceiver = await this.receiveService.findOne({
					where: {
						lnurlId: tag.id,
					},
				});
				console.log(id, query, 'parent');


				// Create a new receiver, this time bolt11 not lnurl
				const receiver = await this.receiveService.create({
					parentId: parentReceiver.id,
					lnurlId: tag.id,
					potId: parentReceiver.potId,
					type: 'bolt11',
					amount: query.amount / MSATOSHIS,
					amountCurrency: 'BTC',
				});
				console.log('here');
				return {
					// disposable: false,
					pr: receiver.data,
					routes: [],
				};
			case 'withdrawRequest':

				const sender = await this.senderService.findOne({
					where: {
						lnurlId: tag.id,
					},
				});
				this.logger.debug(sender.toJSON());
				const parsed = bolt11.decode(query.pr);

				console.log(sender);

				const pot = await this.potService.findForUser(
					sender.userId,
					sender.potId
				);
				this.logger.debug(pot.toJSON());
				this.logger.debug({
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

				return { status: 'OK' }
		}

		throw new HttpException('Unhandleable lnurl request', 400);
	}
}
