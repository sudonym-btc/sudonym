import { Inject, Injectable, Logger } from '@nestjs/common';
import * as ccxt from 'ccxt';
import * as fs from 'fs';
import { CONFIG_FOLDER } from 'helper/config-loader';
import { SettlementService } from '../../module/settlement/settlement.service';

@Injectable()
export class ExchangeService {
	private readonly logger = new Logger(ExchangeService.name);

	@Inject() settlementService: SettlementService;

	exchanges: ccxt.Exchange[] = [];

	async onModuleInit() {
		this.exchanges = fs
			.readdirSync(CONFIG_FOLDER + '/exchanges')
			.filter((f) => f.includes('.json'))
			.map((f) => {
				return new ccxt[f.split('.')[0]](
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

	async fetchPriceAtTime(
		fromCurrency = 'BTC',
		quoteCurrency = 'BTC',
		time?: Date
	) {
		if (fromCurrency == quoteCurrency) return 1;
		const market = await this.fetchMarket(fromCurrency, quoteCurrency);
		const format = (v: number) =>
			this.areSynonymous(quoteCurrency, market.quote) ? v : 1 / v;
		const execute = async () => {
			time = time || new Date();
			if (!time) {
				return (await this.exchanges[0].fetchTicker(market.symbol)).ask;
			}
			const timestamp = Date.UTC(
				time.getUTCFullYear(),
				time.getUTCMonth(),
				time.getUTCDate(),
				time.getUTCHours(),
				time.getUTCMinutes(),
				0,
				0
			);
			this.logger.log(
				'Fetching price',
				market.symbol,
				'1m',
				time,
				timestamp - 1000 * 60 * 50, // Subtract 50 minutes so there will always be a ticker
				100
			);
			return (
				await this.exchanges[0].fetchOHLCV(
					market.symbol,
					'1m',
					timestamp - 1000 * 60 * 50, // Subtract 50 minutes so there will always be a ticker
					100
				)
			).sort((a, b) =>
				// If a is further from the timestamp than b, sort a after b
				Math.abs(a[0] - timestamp) > Math.abs(b[0] - timestamp) ? 1 : -1
			)[0][1];
		};
		return format(await execute());
	}

	async fetchMarket(from, to) {
		this.logger.debug('Finding market for', from, to);
		const markets = await this.exchanges[0].fetchMarkets();
		const market = markets.find(
			(m) =>
				(this.areSynonymous(m.baseId, from) &&
					this.areSynonymous(m.quoteId, to)) ||
				(this.areSynonymous(m.baseId, to) &&
					this.areSynonymous(m.quoteId, from))
		);
		this.logger.debug('Market:', market?.symbol);
		return market;
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

	async trade(from, to, amount) {
		const market = await this.fetchMarket(from, to);
		return await this.exchanges[0]
			.createMarketOrder(
				market.symbol,
				market.quote == to ? 'sell' : 'buy',
				market.quote == to
					? (await this.fetchPriceAtTime(to, from)) * amount
					: amount
			)
			.then(async (order) => {
				await this.settlementService.create({
					exchangeId: this.exchanges[0].name,
					fromCurrency: from,
					toCurrency: to,
					amount: amount,
					orderId: order.id,
				});
			});
	}

	getRealName(currency: string) {
		return (
			Object.keys(synonyms).find((key) =>
				synonyms[key].includes(currency)
			) || currency
		);
	}
	getSynonyms(currency: string) {
		const currKey =
			Object.keys(synonyms).find((i) => synonyms[i].includes(currency)) ||
			currency;
		return [...(synonyms[currKey] ? synonyms[currKey] : []), currency];
	}

	areSynonymous(a: string, b: string) {
		return findOne(this.getSynonyms(a), this.getSynonyms(b));
	}
}

const synonyms = {
	USD: ['USDT'],
};

export const isBitcoin = (type) =>
	['lightningaddress', 'lnurl', 'bolt11', 'bolt12', 'onchain'].includes(type);

/**
 * @description determine if an array contains one or more items from another array.
 * @param {array} haystack the array to search.
 * @param {array} arr the array providing items to check for in the haystack.
 * @return {boolean} true|false if haystack contains at least one item from arr.
 */
const findOne = (haystack, arr) => {
	return arr.some((v) => haystack.includes(v));
};
