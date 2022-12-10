import { HttpException, Inject, Logger } from '@nestjs/common';
import { MSATOSHIS, PaymentRequest, WithdrawRequest } from '@sudonym/models';
import * as bolt11 from 'bolt11';
import { getAddressType } from 'module/action/action.service';
import { Pot } from 'module/pot/pot.model';
import { PotService } from 'module/pot/pot.service';
import { Receiver } from 'module/receiver/receiver.model';
import { ReceiverService } from 'module/receiver/receiver.service';
import { Sender } from 'module/sender/sender.model';
import { SenderService } from 'module/sender/sender.service';
import { TransactionService } from 'module/transaction/transaction.service';
import { LnUrlService } from '../lnurl.service';

export class LnUrlHandlerService {
	@Inject(LnUrlService) lnUrlService: LnUrlService;
	@Inject(ReceiverService) receiveService: ReceiverService;
	@Inject(PotService) potService: PotService;
	@Inject(SenderService) senderService: SenderService;
	@Inject(TransactionService) transactionService: TransactionService;
	private readonly logger = new Logger(this.constructor.name);

	// Function that is called when someone else triggers OUR callbacks.
	async handle(id, query) {
		this.logger.log('Handling lnurl', id, query);
		const tag = await this.serve(id);
		switch (tag.tag) {
			case 'payRequest': {
				// JSON.parse(urldecode(query.payerdata))
				// JSON.parse(urldecode(query.comment))

				const payerData = query.payerdata
					? decodeURIComponent(query.payerdata)
					: '';
				const metadata =
					typeof (tag as PaymentRequest).metadata == 'string'
						? JSON.parse((tag as PaymentRequest).metadata)
						: (tag as PaymentRequest).metadata;
				const description = JSON.stringify(metadata) + payerData;

				const parentReceiver = await this.receiveService.findOne({
					where: {
						lnurlId: id,
					},
				});
				// Create a new receiver, this time bolt11 not lnurl
				const receiver = await this.receiveService.create({
					parentId: parentReceiver.id,
					lnurlId: id,
					potId: parentReceiver.potId,
					type: 'bolt11',
					amount: query.amount / MSATOSHIS,
					amountCurrency: 'BTC',
					comment: query.comment
						? decodeURIComponent(query.comment)
						: null,
					payerData:
						payerData && payerData.length
							? JSON.parse(payerData)
							: null,
					description,
				});
				return {
					// disposable: false,
					pr: receiver.data,
					routes: [],
					// successAction: [
					// {
					// 	"tag": "message",
					// 	"message": "Thank you for using bike-over-ln co! Your rental bike is unlocked now" // Up to 144 characters
					//   }
					//   {
					// 	 "tag": "url",
					// 	 "description": "Thank you for your purchase. Here is your order details", // Up to 144 characters
					// 	 "url": "https://www.ln-service.com/order/<orderId>" // url domain must be the same as `callback` domain at step 3
					//   }
					// ]
				};
			}
			case 'withdrawRequest': {
				const sender = await this.senderService.findOne({
					where: {
						lnurlId: id,
					},
				});
				this.logger.debug(sender.toJSON());
				const parsed = bolt11.decode(query.pr);
				this.logger.debug('withdrawing to ', sender.toJSON());

				const pot = await this.potService.findForUser(
					sender.userId,
					sender.potId
				);
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

				return { status: 'OK' };
			}
		}

		throw new HttpException('Unhandleable lnurl request', 400);
	}

	async serve(id: string): Promise<WithdrawRequest | PaymentRequest> {
		const [tag, receiver, sender] = await Promise.all([
			this.lnUrlService.findOne(id),
			Receiver.findOne({
				where: {
					lnurlId: id,
				},
			}),
			Sender.findOne({
				where: {
					lnurlId: id,
				},
			}),
		]);
		let pot;
		if (receiver?.potId || sender?.potId) {
			pot = await Pot.findByPk(receiver?.potId || sender?.potId);
		}
		if (tag.params.tag === 'payRequest') {
			(tag.params as PaymentRequest).metadata = JSON.parse(
				(tag.params as PaymentRequest).metadata || '[]'
			);
			(tag.params as PaymentRequest).metadata = this.addOrUpdateTag(
				(tag.params as PaymentRequest).metadata,
				'text/plain',
				'payment to sudonym'
			);

			(tag.params as PaymentRequest).metadata = this.addOrUpdateTag(
				(tag.params as PaymentRequest).metadata,
				'text/long-desc',
				'payment to sudonym long description'
			);

			// Add logo
			(tag.params as PaymentRequest).metadata = this.addOrUpdateTag(
				(tag.params as PaymentRequest).metadata,
				'image/png;base64',
				'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'
			);

			// Allow payer to submit following fields
			(tag.params as PaymentRequest).payerData = {
				name: {
					mandatory: false,
				},
				identifier: {
					mandatory: false,
				},
				email: {
					mandatory: false,
				},
			};
			(tag.params as PaymentRequest).metadata = JSON.stringify(
				(tag.params as PaymentRequest).metadata
			);
			(tag.params as PaymentRequest).minSendable = Math.max(
				(tag.params as PaymentRequest).minSendable,
				1000
			);
			(tag.params as PaymentRequest).maxSendable = 0.01 * MSATOSHIS;
			(tag.params as PaymentRequest).commentAllowed = 200;
		} else if (tag.params.tag == 'withdrawRequest') {
			// "payLink": string
			(tag.params as WithdrawRequest).defaultDescription =
				'Withdrawn desciption';
			// (tag.params as WithdrawRequest).payLink = :todo generate payRequest URL;
		}
		return tag.params;
	}

	addOrUpdateTag(metadata, tag, data) {
		const item = metadata.find((i) => i[0] == tag);
		if (item) {
			item[1] = data;
		} else metadata.push([tag, data]);

		return metadata;
	}
}
