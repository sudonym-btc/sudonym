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
		time: Date = new Date()
	) {
		if (fromCurrency == quoteCurrency) return 1;
		const market = await this.fetchMarket(fromCurrency, quoteCurrency);
		const timestamp =
				Date.UTC(
					time.getUTCFullYear(),
					time.getUTCMonth(),
					time.getUTCDate(),
					time.getUTCHours(),
					time.getUTCMinutes(),
					0,
					0
				);
		const response = await this.exchanges[0].fetchOHLCV(
			market.symbol,
			'1m',
			timestamp - 60 * 1000 * 5, // Subtract two minutes so there will always be a ticker
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

	async settle(from, to, amount, side: 'buy' | 'sell' = 'buy') {
		const market = await this.fetchMarket(from, to);
		return await this.exchanges[0]
			.createMarketOrder(
				market.symbol,
				market.baseId == from ? side : side == 'buy' ? 'sell' : side,
				amount
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
