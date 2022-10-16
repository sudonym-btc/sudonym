import { Inject, Injectable, Logger } from '@nestjs/common';
import {
	MSATOSHIS,
	Action,
	ActionParseResponse,
	Payment,
	Withdraw,
	TAddressType,
} from '@sudonym/models';
import * as bolt11 from 'bolt11';
import { LightningNodeService } from '../../service/lightning-node/lightning-node.service';
import { CurrencyService } from '../currency/currency.service';
import { Transaction } from '../transaction/transaction.model';
import { TransactionService } from '../transaction/transaction.service';
import {
	AddressParser,
	validateInternetIdentifier,
} from './address-parser/address-parser';
import { fetchHttpOpts } from './address-parser/http-agent';
import fetch from 'node-fetch';
import { ReceiverService } from 'module/receiver/receiver.service';
import { Receiver } from 'module/receiver/receiver.model';

@Injectable()
export class ActionService {
	@Inject(CurrencyService) currencyService: CurrencyService;
	@Inject(LightningNodeService) lightningNodeService: LightningNodeService;
	@Inject(TransactionService) transactionService: TransactionService;
	@Inject(ReceiverService) receiverService: ReceiverService;
	@Inject(AddressParser) addressParser: AddressParser;
	private readonly logger = new Logger(this.constructor.name);

	async parse(invoice): Promise<ActionParseResponse> {
		return ActionParseResponse.from(
			await this.addressParser.parse(invoice)
		);
	}

	async getInfo(action: Payment | Withdraw): Promise<Action> {
		if (action instanceof Payment) {
			const t = getAddressType(action.originalAddress);

			action.currency = action.currency || 'BTC';
			const btcAmount =
				action.currency == 'BTC'
					? action.amount
					: (
							await this.currencyService.convert(
								action.currency,
								'BTC',
								action.amount
							)
					  ).amount;
			const mSatoshiAmount = Math.round(btcAmount * MSATOSHIS);

			switch (t) {
				case 'bolt11':
					return Action.from({
						...action,
						address: action.originalAddress,
						fee: (await this.lightningNodeService.getFees(
							bolt11.decode(action.originalAddress).payeeNodeKey,
							mSatoshiAmount
						)) / MSATOSHIS,
						feeCurrency: 'BTC',
					});
				case 'bolt12':
					const offerInvoice =
						await this.lightningNodeService.fetchOfferInvoice(
							action.originalAddress
						);

					return Action.from({
						...action,
						address: offerInvoice,
						fee:
							(await this.lightningNodeService.getFees(
								bolt11.decode(offerInvoice).payeeNodeKey,
								mSatoshiAmount
							)) / MSATOSHIS,
						feeCurrency: 'BTC',
						remoteResponse: await this.addressParser.parse(
							offerInvoice
						),
					});
				case 'lightningaddress':
				case 'lnurl':
					const address = (
						await this.getCallback(
							(action.remoteResponse.data as any).callback,
							{
								amount: mSatoshiAmount,
								comment: action.comment,
								payerData: {
									// "name": string, // free form string
									// "pubkey": string, // hex(<randomly generated secp256k1 pubkey>),
									// "auth": {
									//   "key": string, // hex(<linkingKey>)
									//   "k1": string, // same as received from service on section 1
									//   "sig": string, // following LUD-04: hex(sign(hexToBytes(<k1>), <linkingPrivKey>))
									// },
									// "email": string,
									// "identifier": string,
								},
							}
						)
					).pr;

					return Action.from({
						...action,
						address,
						fee:
							(await this.lightningNodeService.getFees(
								bolt11.decode(address).payeeNodeKey,
								mSatoshiAmount
							)) / MSATOSHIS,
						feeCurrency: 'BTC',
					});
				case 'onchain':
					return action;
			}
		} else if (action instanceof Withdraw) {
			return action;
		}
	}

	async execute(action: Action): Promise<Transaction | Receiver> {
		if (action instanceof Payment) {
			return this.transactionService.create({
				originalAddress: action.originalAddress,
				address: action.address,
				type: getAddressType(action.originalAddress),
				amount: action.amount,
				currencyCode: action.currency,
				outgoing: true,
				potId: action.potId,
			});
		} else if (action instanceof Withdraw) {
			this.logger.warn('Withdrawing', action);

			const receiver = await this.receiverService.create({
				potId: action.potId,
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

			const response = this.getCallback(
				action.remoteResponse.data.callback,
				{
					k1: action.remoteResponse.data.k1,
					pr: receiver.data,
				}
			);

			return receiver;
		}
	}

	async getCallback(callback, params) {
		const u = new URL(callback);
		for (const key in params) {
			u.searchParams.append(key, params[key]);
		}
		this.logger.debug('Getting callback ', u.toString());
		return fetch(u, fetchHttpOpts).then((r) => r.json());
	}
}

export const getAddressType = (address: string): TAddressType => {
	if (validateInternetIdentifier(address)) {
		return 'lightningaddress';
	} else if (address.startsWith('lnurl1')) {
		return 'lnurl';
	} else if (address.startsWith('lno1')) {
		return 'bolt12';
	} else if (
		address.startsWith('lnbc') ||
		address.startsWith('lntb') ||
		address.startsWith('lntbs') ||
		address.startsWith('lnbcrt')
	) {
		return 'bolt11';
	} else {
		return 'onchain';
	}
};
