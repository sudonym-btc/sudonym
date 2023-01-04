import { Inject, Injectable } from '@nestjs/common';
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
			switch (params.type) {
				case 'lnurl': {
					const { entity: tag } =
						await this.lnUrlService.createWithdrawRequest({
							minWithdrawable: 0,
							maxWithdrawable: 0,
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
