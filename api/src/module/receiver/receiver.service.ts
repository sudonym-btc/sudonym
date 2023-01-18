import { Inject, Injectable } from '@nestjs/common';
import { MSATOSHIS } from '@sudonym/models';
import { Config } from 'config/config';
import * as lnurl from 'lnurl';
import { PotService } from 'module/pot/pot.service';
import { LightningNodeService } from 'service/lightning-node/lightning-node.service';
import { BaseService } from '../base.service';
import { CurrencyService } from '../currency/currency.service';
import { LnUrlService } from '../lightning/lnurl/lnurl.service';
import { Receiver } from './receiver.model';

@Injectable()
export class ReceiverService extends BaseService(Receiver) {
	@Inject(Config) private readonly config: Config;
	@Inject(CurrencyService) private currencyService: CurrencyService;
	@Inject(PotService) private potService: PotService;
	@Inject(LightningNodeService)
	private lightningNodeService: LightningNodeService;
	@Inject(LnUrlService) private lnUrlService: LnUrlService;

	async onModuleInit() {
		super.onModuleInit();

		this.beforeCreate.hook(async (params) => {
			const amountInBTC = params.amount
				? (
						await this.currencyService.convert(
							params.amountCurrency,
							'BTC',
							params.amount
						)
				  ).amount
				: null;
			params.potId =
				params.potId || (await this.potService.findForUser()).id;

			switch (params.type) {
				case 'bolt11': {
					params.data = (
						await this.lightningNodeService.createInvoice(
							Math.round(amountInBTC * MSATOSHIS),
							undefined,
							params.description,
							!!params.description
						)
					).bolt11;
					break;
				}
				case 'bolt12':
					params.data = (
						await this.lightningNodeService.createOffer(
							amountInBTC * MSATOSHIS
						)
					).bolt12;
					break;
				case 'lnurl': {
					const { entity: tag } =
						await this.lnUrlService.createPayRequest(
							Math.floor(amountInBTC * MSATOSHIS)
						);
					params.data = lnurl.encode(
						this.config.selfUrl + '/lnurl/serve/' + tag.id
					);
					params.lnurlId = tag.id;
					break;
				}
				case 'onchain':
					params.data =
						(
							await this.lightningNodeService.generateOnChainAddress()
						).address +
						(amountInBTC ? '?amount=' + amountInBTC : '');
					break;
			}
		});
	}
}
