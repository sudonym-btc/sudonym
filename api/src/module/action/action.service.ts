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

@Injectable()
export class ActionService {
	@Inject(CurrencyService) currencyService: CurrencyService;
	@Inject(LightningNodeService) lightningNodeService: LightningNodeService;
	@Inject(TransactionService) transactionService: TransactionService;
	@Inject(AddressParser) addressParser: AddressParser;
	private readonly logger = new Logger(ActionService.name);

	async parse(invoice): Promise<ActionParseResponse> {
		return ActionParseResponse.from(await this.addressParser.parse(invoice));
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
						fee: await this.lightningNodeService.getFees(
							bolt11.decode(action.address).payeeNodeKey,
							mSatoshiAmount
						),
					});
				case 'bolt12':
					const offerInvoice =
						await this.lightningNodeService.fetchOfferInvoice(
							action.originalAddress
						);

					return Action.from({
						...action,
						address: offerInvoice,
						fee: await this.lightningNodeService.getFees(
							bolt11.decode(offerInvoice).payeeNodeKey,
							mSatoshiAmount
						),
						remoteResponse: await this.addressParser.parse(
							offerInvoice
						),
					});
				case 'lightningaddress':
				case 'lnurl':
					console.log(action.remoteResponse);
					console.log(await this.getCallback(
						action.remoteResponse.data.callback,
						{ amount: mSatoshiAmount }
					));
					return Action.from({
						...action,
						address: (
							await this.getCallback(
								(action.remoteResponse.data as any).callback,
								{ amount: mSatoshiAmount }
							)
						).pr,
					});
				case 'onchain':
					return action;
			}
		} else if (action instanceof Withdraw) {
			return action;
		}
	}

	async execute(action: Action): Promise<Transaction> {
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
		}
	}

	async getCallback(callback, params) {
		console.log(callback);
		const u = new URL(callback);
		for (const key in params) {
			u.searchParams.append(key, params[key]);
		}
		this.logger.debug("Getting callback ", u.toString());
		return fetch(
			u,
			fetchHttpOpts
		).then((r) => r.json());
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
