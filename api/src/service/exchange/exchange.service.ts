import { CACHE_MANAGER, Inject, Injectable, Logger } from '@nestjs/common';
import { Cache } from 'cache-manager';
import { Config } from 'config/config';
import * as fs from 'fs';
import { CONFIG_FOLDER } from 'helper/config-loader';
import { BalanceService } from './balance.service';
import { Exchange, getCurrencySynonyms, getRealCurrencyName } from './exchange';

@Injectable()
export class ExchangeService {
	private readonly logger = new Logger(ExchangeService.name);
	@Inject(CACHE_MANAGER) private cacheManager: Cache;
	@Inject(BalanceService) private readonly balanceService: BalanceService;
	@Inject() config: Config;

	exchanges: Exchange[] = [];

	async onModuleInit() {
		this.exchanges = fs
			.readdirSync(CONFIG_FOLDER + '/exchanges')
			.filter((f) => f.includes('.json'))
			.map((f) => {
				return new Exchange[f.split('.')[0]](
					JSON.parse(
						fs.readFileSync(CONFIG_FOLDER + '/exchanges/' + f, {
							encoding: 'utf8',
						})
					)
				);
			});

		for (const exchange of this.exchanges) {
			await exchange.fetchMarkets();
		}
	}

	async buy(currency: string, amount: number) {
		this.logger.debug(`Buying ${amount} of ${currency}`);
		const exchangeFunds = await this.listFunds();
		const totalFunds = await this.balanceService.getTotalFunds();
		const liabilities = await this.balanceService.getLiabilities();

		// For each exchange
		for (const exchange of this.exchanges) {
			// Check which currencies on this exchange we have more of than liabilties
			const surplusCurrencies = Object.keys(
				exchangeFunds[exchange.id]
			).filter(
				(i) =>
					totalFunds[getRealCurrencyName(i)] >
					liabilities[getRealCurrencyName(i)]
			);

			// For each surplus currency on the exchange
			for (const surplusCurrency of surplusCurrencies) {
				const surplusAmount =
					totalFunds[getRealCurrencyName(surplusCurrency)] -
					(liabilities[getRealCurrencyName(surplusCurrency)] || 0);

				// Check if surplus is enough to settle into any synonym of liability
				for (const synonymousCurrency of getCurrencySynonyms(
					currency
				)) {
					try {
						const surplusAmountInLiabilityCurrency =
							(await exchange.fetchPriceAtTime(
								surplusCurrency,
								synonymousCurrency
							)) *
							Math.min(
								exchangeFunds[exchange.id][surplusCurrency],
								surplusAmount
							);
						if (surplusAmountInLiabilityCurrency > amount) {
							return await exchange.trade(
								surplusCurrency,
								synonymousCurrency,
								amount
							);
						} else {
							this.logger.debug(
								'Did not have enough ' +
									surplusCurrency +
									' to buy ' +
									synonymousCurrency
							);
						}
					} catch (e) {
						this.logger.warn(e);
					}
				}
			}
		}
		this.logger.warn('Could not make trade');
	}

	async fetchPriceAtTime(
		fromCurrency = 'BTC',
		quoteCurrency = 'BTC',
		time?: Date
	) {
		const errors = [];
		for (const exchange of this.exchanges) {
			const key = `${exchange.name}${fromCurrency}/${quoteCurrency}:${time}`;
			const ttl = time ? 0 : 60;
			return this.cacheManager.wrap(
				key,
				() =>
					exchange.fetchPriceAtTime(
						fromCurrency,
						quoteCurrency,
						time
					),
				ttl
			);
		}
	}

	async listFunds(): Promise<{ [key: string]: { [key: string]: number } }> {
		const funds = {};
		for (const exchange of this.exchanges) {
			funds[exchange.id] = await exchange
				.fetchBalance()
				.then((u) => u.free);
		}
		return funds;
	}
}
