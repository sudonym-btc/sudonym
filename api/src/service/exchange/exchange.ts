import { Logger } from '@nestjs/common';
import * as ccxt from 'ccxt';

export class Exchange {
	private readonly logger = new Logger(Exchange.name);

	constructor(public exchange: ccxt.Exchange) {}

	async fetchPriceAtTime(
		fromCurrency = 'BTC',
		quoteCurrency = 'BTC',
		time?: Date
	) {
		if (fromCurrency == quoteCurrency) return 1;
		const market = await this.fetchMarket(fromCurrency, quoteCurrency);
		const format = (v: number) =>
			currenciesAreSynonymous(quoteCurrency, market.quote) ? v : 1 / v;
		const execute = async () => {
			time = time || new Date();
			if (!time) {
				return (await this.exchange.fetchTicker(market.symbol)).ask;
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
				await this.exchange.fetchOHLCV(
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
		const markets = await this.exchange.fetchMarkets();
		const market = markets.find(
			(m) =>
				(currenciesAreSynonymous(m.baseId, from) &&
					currenciesAreSynonymous(m.quoteId, to)) ||
				(currenciesAreSynonymous(m.baseId, to) &&
					currenciesAreSynonymous(m.quoteId, from))
		);
		this.logger.debug('Market:', market?.symbol);
		return market;
	}

	async trade(from, to, amount) {
		const market = await this.fetchMarket(from, to);
		return await this.exchange.createMarketOrder(
			market.symbol,
			market.quote == to ? 'sell' : 'buy',
			market.quote == to
				? (await this.fetchPriceAtTime(to, from)) * amount
				: amount
		);
	}
}

export const getRealCurrencyName = (currency: string) => {
	return (
		Object.keys(synonyms).find((key) => synonyms[key].includes(currency)) ||
		currency
	);
};
export const getCurrencySynonyms = (currency: string) => {
	const currKey =
		Object.keys(synonyms).find((i) => synonyms[i].includes(currency)) ||
		currency;
	return [...(synonyms[currKey] ? synonyms[currKey] : []), currency];
};

export const currenciesAreSynonymous = (a: string, b: string) => {
	return findOne(getCurrencySynonyms(a), getCurrencySynonyms(b));
};

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
