import { Inject, Injectable } from '@nestjs/common';
import { Receiver } from './receiver.model';
import { LnUrlService } from '../lightning/lnurl/lnurl.service';
import { LightningNodeService } from 'service/lightning-node/lightning-node.service';
import { BaseService } from '../base.service';
import * as lnurl from 'lnurl';
import { getConfig } from 'config/config';
import { CurrencyCode, MSATOSHIS, TAddressType } from '@sudonym/models';
import { CurrencyService } from '../currency/currency.service';
import { ReceiveQuery } from './receiver.controller';

@Injectable()
export class ReceiverService extends BaseService(Receiver) {
	@Inject(CurrencyService) currencyService: CurrencyService;
	@Inject(LightningNodeService) lightningNodeService: LightningNodeService;
	@Inject(LnUrlService) lnUrlService: LnUrlService;

	async getInvoice(
		query: ReceiveQuery
	) {
		const amountInBTC =
			query.amountCurrency == 'BTC'
				? query.amount
				: (await this.currencyService.convert(query.amountCurrency, 'BTC', query.amount))
					.amount;
		const mSatoshiAmount = Math.round(amountInBTC * MSATOSHIS);

		if (query.type != 'bolt11' && query.type != 'lnurl') {
			const exists = await Receiver.findOne({
				where: {
					potId: query.potId,
					type: query.type,
					amount: query.amount,
					amountCurrency: query.amountCurrency,
				},
			});
			if (exists) return exists;
		}
		let params: any = {};

		switch (query.type) {
			case 'bolt11':
				params.data = (
					await this.lightningNodeService.createInvoice(
						mSatoshiAmount
					)
				).bolt11;
				break;
			case 'bolt12':
				params.data = (
					await this.lightningNodeService.createOffer(mSatoshiAmount)
				).bolt12;
				break;
			case 'lnurl':
				const tag = await this.lnUrlService.createPayRequest(
					query.potId,
					mSatoshiAmount
				);
				params.data = lnurl.encode(getConfig().selfUrl + '/lnurl/' + tag.id);
				params.lnurlId = tag.id;
				break;
			case 'onchain':
				params.data = (
					await this.lightningNodeService.generateOnChainAddress()
				).address;
				break;
		}

		const receiver = await Receiver.create({
			potId: query.potId,
			amount: Number(amountInBTC),
			currency: 'BTC',
			type: query.type,
			...params,
		});

		return receiver;
	}
}
