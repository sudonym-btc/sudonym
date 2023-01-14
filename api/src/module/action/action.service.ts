import { HttpException, Inject, Injectable, Logger } from '@nestjs/common';
import {
	Action,
	ActionParseResponse,
	Payment,
	Withdraw,
} from '@sudonym/models';
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

	async parse(action): Promise<ActionParseResponse> {
		const [type, trimmedAddress] = this.addressParser.getAddressType(
			action.originalAddress
		);
		this.logger.debug('Parsing', trimmedAddress, type);
		let returnedAction: Payment | Withdraw;
		switch (type) {
			case 'lnurl':
			case 'lightningaddress': {
				returnedAction = await this.lnurlOperationsService.parse(
					action
				);
				break;
			}
			case 'onchain': {
				returnedAction = await this.onchainOperationsService.parse(
					action
				);
				break;
			}
			case 'bolt11': {
				returnedAction = await this.lightningOperationsService.parse(
					action
				);
				break;
			}
			default: {
				throw new HttpException('Invalid address', 400);
			}
		}
		const a = ActionParseResponse.from(returnedAction);
		if (
			returnedAction.remoteResponse &&
			(returnedAction.remoteResponse.success == false ||
				returnedAction.remoteResponse.data?.status?.toLowerCase() ==
					'error')
		) {
			throw a;
		}
		return a;
	}

	async info(action): Promise<Action> {
		const [type, trimmedAddress] = this.addressParser.getAddressType(
			action.originalAddress
		);
		this.logger.debug('Getting info', trimmedAddress, type);
		switch (type) {
			case 'lnurl':
			case 'lightningaddress': {
				return this.lnurlOperationsService.getInfo(action);
			}
			case 'onchain': {
				return this.onchainOperationsService.getInfo(action);
			}
			case 'bolt11': {
				return this.lightningOperationsService.getInfo(action);
			}
			default: {
				throw new HttpException('Invalid address', 400);
			}
		}
	}

	async execute(action: Action): Promise<Transaction | Receiver> {
		if (action instanceof Payment) {
			const refreshedAction = (await this.info(action)) as Payment; // Refetch info to get the newest information and make sure receiving end gets input comment information

			this.logger.log({
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
			});
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
			).entity;
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
			const response = this.lnurlOperationsService.fetchRemoteLnUrl(
				action.remoteResponse.data.callback,
				{
					k1: action.remoteResponse.data.k1,
					pr: receiver.data,
				}
			);

			return receiver;
		}
	}
}
