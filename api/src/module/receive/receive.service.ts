import { Inject, Injectable } from '@nestjs/common';
import { Receiver } from './receiver.model';
import { LnUrlService } from '../lightning/lnurl/lnurl.service';
import { LightningNodeService } from 'src/service/lightning-node/lightning-node.service';
import { BaseService } from '../base.service';
import * as lnurl from 'lnurl';
import { getConfig } from 'src/config/config';
import { CurrencyCode, MSATOSHIS, TAddressType } from '@sudonym/models';
import { CurrencyService } from '../currency/currency.service';

@Injectable()
export class ReceiveService extends BaseService(Receiver) {
	@Inject(CurrencyService) currencyService: CurrencyService;
	@Inject(LightningNodeService) lightningNodeService: LightningNodeService;
	@Inject(LnUrlService) lnUrlService: LnUrlService;

	async getInvoice(
		potId,
		type: TAddressType,
		amount = 0,
		currency: CurrencyCode = 'BTC'
	) {
		const amountInBTC =
			currency == 'BTC'
				? amount
				: (await this.currencyService.convert(currency, 'BTC', amount))
						.amount;
		const mSatoshiAmount = Math.round(amountInBTC * MSATOSHIS);

		if (type != 'bolt11' && type != 'lnurl') {
			const exists = await Receiver.findOne({
				where: {
					potId,
					type,
					amount,
					currency,
				},
			});
			if (exists) return exists;
		}
		let data;

		switch (type) {
			case 'bolt11':
				data = (
					await this.lightningNodeService.createInvoice(
						mSatoshiAmount
					)
				).bolt11;
				break;
			case 'bolt12':
				data = (
					await this.lightningNodeService.createOffer(mSatoshiAmount)
				).bolt12;
				break;
			case 'lnurl':
				const tag = await this.lnUrlService.createPayRequest(
					potId,
					mSatoshiAmount
				);
				data = lnurl.encode(getConfig().selfUrl + '/lnurl/' + tag.id);
				break;
			case 'onchain':
				data = (
					await this.lightningNodeService.generateOnChainAddress()
				).address;
				break;
		}
		return Receiver.create({
			potId,
			amount: Number(amountInBTC),
			currency: 'BTC',
			type,
			data,
		});
	}
}
