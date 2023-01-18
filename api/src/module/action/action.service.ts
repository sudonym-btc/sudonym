import { HttpException, Inject, Injectable, Logger } from '@nestjs/common';
import {
	Action,
	ActionParseResponse,
	Payment,
	PaymentRequestCallback,
	Withdraw,
} from '@sudonym/models';
import * as bolt11 from 'bolt11';
import { LNURLProtocolError } from 'helper/errors';
import { Receiver } from 'module/receiver/receiver.model';
import { ReceiverService } from 'module/receiver/receiver.service';
import { LightningNodeService } from '../../service/lightning-node/lightning-node.service';
import { CurrencyService } from '../currency/currency.service';
import { Transaction } from '../transaction/transaction.model';
import { TransactionService } from '../transaction/transaction.service';
import { AddressParser } from './address-parser.service';
import { LightningOperationsService } from './lightning-operations.service';
import { LnurlOperationsService } from './lnurl-operations.service';
import { OnchainOperationsService } from './onchain-operations.service';

@Injectable()
export class ActionService {
	@Inject(AddressParser) addressParser: AddressParser;
	@Inject(CurrencyService) currencyService: CurrencyService;
	@Inject(LightningNodeService) lightningNodeService: LightningNodeService;
	@Inject(LightningOperationsService)
	lightningOperationsService: LightningOperationsService;
	@Inject(LnurlOperationsService)
	lnurlOperationsService: LnurlOperationsService;
	@Inject(OnchainOperationsService)
	onchainOperationsService: OnchainOperationsService;
	@Inject(TransactionService) transactionService: TransactionService;
	@Inject(ReceiverService) receiverService: ReceiverService;
	private readonly logger = new Logger(this.constructor.name);

	async parse(addr: string): Promise<ActionParseResponse> {
		const [type, trimmedAddress] = this.addressParser.getAddressType(addr);
		this.logger.debug('Parsing', trimmedAddress, type);
		let returnedAction: Payment | Withdraw;
		switch (type) {
			case 'lnurl':
			case 'lightningaddress': {
				returnedAction = await this.lnurlOperationsService.parse(
					trimmedAddress
				);
				break;
			}
			case 'onchain': {
				returnedAction = await this.onchainOperationsService.parse(
					trimmedAddress
				);
				break;
			}
			case 'bolt11': {
				returnedAction = await this.lightningOperationsService.parse(
					trimmedAddress
				);
				break;
			}
			default: {
				throw new HttpException('Invalid address', 400);
			}
		}
		const a = ActionParseResponse.from(returnedAction);
		if (returnedAction.remoteResponses[0]?.success == false) {
			throw a;
		}
		return a;
	}

	async info<T = Payment | Withdraw>(action): Promise<T> {
		const [type, trimmedAddress] = this.addressParser.getAddressType(
			action.originalAddress
		);
		this.logger.debug('Getting info', trimmedAddress, type);
		switch (type) {
			case 'lnurl':
			case 'lightningaddress': {
				return this.lnurlOperationsService.getInfo(action) as T;
			}
			case 'onchain': {
				return this.onchainOperationsService.getInfo(action) as T;
			}
			case 'bolt11': {
				return this.lightningOperationsService.getInfo(action) as T;
			}
			default: {
				throw new HttpException('Invalid address', 400);
			}
		}
	}

	async execute<T = Transaction | Receiver>(action: Action): Promise<T> {
		if (action instanceof Payment) {
			const [type] = await this.addressParser.getAddressType(
				action.originalAddress
			);
			let refreshedAction: Payment;
			switch (type) {
				case 'lnurl':
				case 'lightningaddress': {
					refreshedAction =
						(await this.lnurlOperationsService.execute(
							action
						)) as Payment;
					break;
				}
				case 'onchain': {
					refreshedAction =
						(await this.onchainOperationsService.execute(
							action
						)) as Payment;
					break;
				}
				case 'bolt11': {
					refreshedAction =
						(await this.lightningOperationsService.execute(
							action
						)) as Payment;
					break;
				}
				default: {
					throw new HttpException('Invalid address', 400);
				}
			}

			console.log('here');

			const btcAmountWanted = await this.addressParser.getMSatAmount(
				action
			);

			if (
				['lnurl', 'lightningaddress'].includes(
					this.addressParser.getAddressType(
						refreshedAction.originalAddress
					)[0]
				)
			) {
				// Throw error if amounts not the same
				if (
					btcAmountWanted /
						Math.abs(
							parseInt(
								bolt11.decode(
									(
										refreshedAction.remoteResponses.at(-1)
											.data as PaymentRequestCallback
									).pr
								).millisatoshis
							) - btcAmountWanted
						) <
					100
				) {
					throw new LNURLProtocolError(
						'Returned an invoice of a higher amount than requested'
					);
				}
			}
			console.log('now here');
			this.logger.log(refreshedAction);
			return (
				await this.transactionService.create({
					originalAddress: refreshedAction.originalAddress,
					address: refreshedAction.address,
					type: this.addressParser.getAddressType(
						refreshedAction.originalAddress
					)[0],
					amount: refreshedAction.amount,
					currencyCode: refreshedAction.currency,
					description: refreshedAction.description,
					comment: refreshedAction.comment,
					outgoing: true,
					potId: refreshedAction.potId,
				})
			).entity as T;
		} else if (action instanceof Withdraw) {
			this.logger.debug('Withdrawing', action);
			const { entity: receiver } = await this.receiverService.create({
				potId: action.potId,
				...(action.billSplitParticipantId
					? {
							parentId: (
								await this.receiverService.list({
									where: {
										billSplitParticipantId:
											action.billSplitParticipantId,
									},
									// order: [['createdAt', 'DESC']],
									// limit: 1,
								})
							).data[0]?.id,
					  }
					: {}),
				billSplitParticipantId: action.billSplitParticipantId,
				amountCurrency: 'BTC',
				amount: (
					await this.currencyService.convert(
						action.currency,
						'BTC',
						action.amount
					)
				).amount,
				type: 'bolt11',
			});

			// Trigger remote action, fail if responds with error
			await this.lnurlOperationsService.fetchRemoteLnUrl(
				action.remoteResponses.at(-1).data.callback,
				{
					k1: action.remoteResponses.at(-1).data.k1,
					pr: receiver.data,
				}
			);

			return receiver as T;
		}
	}
}
