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

	onModuleInit() {
		this.beforeCreate.hook(async (params) => {
			const amountInBTC = (
				await this.currencyService.convert(
					params.amountCurrency || 'BTC',
					'BTC',
					params.amount
				)
			).amount;
			const mSatoshiAmount = Math.round(amountInBTC * MSATOSHIS);

			params.amount = Number(amountInBTC);

			switch (params.type) {
				case 'lnurl':
					const tag = await this.lnUrlService.createWithdrawRequest({
						minWithdrawable: params.limitMin ? params.limitMin * MSATOSHIS : 0,
						maxWithdrawable: params.limitMax ? params.limitMax * MSATOSHIS : 99999999
					}
					);
					// todo: replace with max account balance
					params.data = getConfig().selfUrl + '/lnurl/' + tag.id
					params.lnurlId = tag.id;
					break;
			}
		});
	}
}
