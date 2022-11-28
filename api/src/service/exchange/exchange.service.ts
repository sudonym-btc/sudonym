import { Inject, Injectable, Logger } from '@nestjs/common';
import * as ccxt from 'ccxt';
import * as fs from 'fs';
import { SettlementService } from '../../module/settlement/settlement.service';

@Injectable()
export class ExchangeService {
	private readonly logger = new Logger(ExchangeService.name);

	@Inject() settlementService: SettlementService;

	exchanges: ccxt.Exchange[] = [];

	async onModuleInit() {
		this.exchanges = fs
			.readdirSync('src/config/exchanges')
			.filter((f) => f.includes('.json'))
			.map((f) => {
				return new ccxt[f.split('.')[0]](
					JSON.parse(
						fs.readFileSync('src/config/exchanges/' + f, {
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
		const timestamp = time
			? Date.UTC(
					time.getUTCFullYear(),
					time.getUTCMonth(),
					time.getUTCDate(),
					time.getUTCHours(),
					time.getUTCMinutes(),
					0,
					0
			  )
			: null;
		if (time)
			console.log(
				market.symbol,
				'1m',
				time,
				timestamp, // Subtract two minutes so there will always be a ticker
				100
			);
		const response = await this.exchanges[0].fetchOHLCV(
			market.symbol,
			'1m',
			timestamp - 1000 * 60 * 2, // Subtract two minutes so there will always be a ticker
			100
		);
		return market.quote == quoteCurrency
			? response[0][1]
			: 1 / response[0][1];
	}

	async fetchMarket(from, to) {
		this.logger.debug('Finding market for', from, to);
		const markets = await this.exchanges[0].fetchMarkets();
		const market = markets.find(
			(m) =>
				(m.baseId == from && m.quoteId == to) ||
				(m.baseId == to && m.quoteId == from)
		);
		this.logger.debug('Found market', market.symbol);
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
}

export const isBitcoin = (type) =>
	['lightningaddress', 'lnurl', 'bolt11', 'bolt12', 'onchain'].includes(type);
