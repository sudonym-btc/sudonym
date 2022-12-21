import { Inject, Injectable } from '@nestjs/common';
import { MSATOSHIS } from '@sudonym/models';
import { Config } from 'config/config';
import * as lnurl from 'lnurl';
import { TransactionService } from 'module/transaction/transaction.service';
import { BaseService } from '../base.service';
import { CurrencyService } from '../currency/currency.service';
import { LnUrlService } from '../lightning/lnurl/lnurl.service';
import { Sender } from './sender.model';

@Injectable()
export class SenderService extends BaseService(Sender) {
	@Inject(CurrencyService) currencyService: CurrencyService;
	@Inject(LnUrlService) lnUrlService: LnUrlService;
	@Inject(TransactionService) transactionService: TransactionService;
	@Inject(Config) private readonly config: Config;

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
				case 'lnurl': {
					const tag = await this.lnUrlService.createWithdrawRequest({
						minWithdrawable: params.limitMin
							? params.limitMin * MSATOSHIS
							: 0,
						maxWithdrawable: params.limitMax
							? params.limitMax * MSATOSHIS
							: 99999999,
					});
					// todo: replace with max account balance
					params.data = lnurl.encode(
						this.config.selfUrl + '/lnurl/serve/' + tag.id
					);
					params.lnurlId = tag.id;
					break;
				}
			}
		});
	}

	async amountLeft(sender: Sender) {
		const txs = await this.transactionService.list({
			where: {
				senderId: sender.id,
			},
		});
		return (
			sender.limitMax -
			(
				await Promise.all(
					txs.data.map((tx) =>
						this.currencyService.convert(
							tx.currencyCode,
							sender.amountCurrency,
							tx.amount,
							tx.createdAt
						)
					)
				)
			).reduce((acc, curr) => acc + curr.amount, 0)
		);
	}
}
