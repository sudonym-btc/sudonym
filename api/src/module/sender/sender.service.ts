import { Inject, Injectable } from '@nestjs/common';
import { LnUrlService } from '../lightning/lnurl/lnurl.service';
import { BaseService } from '../base.service';
import { CurrencyService } from '../currency/currency.service';
import { Sender } from './sender.model';
import { RequestType } from 'helper/parse-request.decorator';
import { RecursivePartial } from 'sequelize-typescript/dist/shared/types';
import { MSATOSHIS } from '@sudonym/models';
import * as lnurl from 'lnurl';
import { getConfig } from 'config/config';

@Injectable()
export class SenderService extends BaseService(Sender) {
	@Inject(CurrencyService) currencyService: CurrencyService;
	@Inject(LnUrlService) lnUrlService: LnUrlService;

	async create(params: RecursivePartial<Sender>, req?: RequestType) {
		const amountInBTC =
			params.amountCurrency == 'BTC'
				? params.amount
				: (await this.currencyService.convert(params.amountCurrency, 'BTC', params.amount))
					.amount;
		const mSatoshiAmount = Math.round(amountInBTC * MSATOSHIS);

		let data;
		switch (params.type) {
			case 'lnurl':
				const tag = await this.lnUrlService.createWithdrawRequest(
					params.potId,
					mSatoshiAmount
				);
				data = lnurl.encode(getConfig().selfUrl + '/lnurl/' + tag.id);
				break;
		}

		const sender = await super.create({
			...params,
			amount: Number(amountInBTC),
			data,
		});

		return sender;
	}
}
