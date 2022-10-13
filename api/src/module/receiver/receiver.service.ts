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
import { PotService } from 'module/pot/pot.service';

@Injectable()
export class ReceiverService extends BaseService(Receiver) {
	@Inject(CurrencyService) currencyService: CurrencyService;
	@Inject(PotService) potService: PotService;
	@Inject(LightningNodeService) lightningNodeService: LightningNodeService;
	@Inject(LnUrlService) lnUrlService: LnUrlService;

	async getInvoice(query: ReceiveQuery) {
		return this.create(query);
	}

	async onModuleInit() {
		super.onModuleInit();

		this.beforeCreate.hook(async (params) => {
			if (!['bolt11', 'lnurl'].includes(params.type)) {
				const exists = await Receiver.findOne({
					where: {
						potId: params.potId,
						type: params.type,
						amount: params.amount,
						amountCurrency: params.amountCurrency,
					},
				});
				if (exists) return exists;
			}

			const amountInBTC =
				params.amountCurrency == 'BTC'
					? params.amount
					: (
							await this.currencyService.convert(
								params.amountCurrency,
								'BTC',
								params.amount
							)
					  ).amount;
			const mSatoshiAmount = Math.round(amountInBTC * MSATOSHIS);

			params.potId = params.potId || (await this.potService.findForUser()).id;
			params.amountCurrency = "BTC";
			params.amount = Number(amountInBTC);
			console.log(params);
			console.log(typeof params.amount);

			switch (params.type) {
				case 'bolt11':
					params.data = (
						await this.lightningNodeService.createInvoice(
							mSatoshiAmount
						)
					).bolt11;
					break;
				case 'bolt12':
					params.data = (
						await this.lightningNodeService.createOffer(
							mSatoshiAmount
						)
					).bolt12;
					break;
				case 'lnurl':
					const tag = await this.lnUrlService.createPayRequest(
						mSatoshiAmount
					);
					params.data = lnurl.encode(
						getConfig().selfUrl + '/lnurl/' + tag.id
					);
					params.lnurlId = tag.id;
					break;
				case 'onchain':
					params.data = (
						await this.lightningNodeService.generateOnChainAddress()
					).address;
					break;
			}
		});
	}
}
