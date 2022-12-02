import { Balances, Exchange, Market, OHLCV, Order, Params } from 'ccxt';
import { ExchangeService } from 'service/exchange/exchange.service';

class MockExchange extends Exchange {
	balances = {
		info: {
			free: 1,
			used: 1,
			total: 1,
		},
		free: {
			BTC: 10,
		},
	};

	_markets: Market[] = [
		{
			id: 'BTC/USDT',
			symbol: 'BTC/USDT',
			base: 'BTC',
			quote: 'USDT',
			baseId: 'BTC',
			quoteId: 'USDT',
			precision: {
				amount: 1,
				price: 0.01,
			},
			limits: {},
			info: {},
		},
		{
			id: 'GBP/USDT',
			symbol: 'GBP/USDT',
			base: 'GBP',
			quote: 'USDT',
			baseId: 'GBP',
			quoteId: 'USDT',
			precision: {
				amount: 1,
				price: 0.01,
			},
			limits: {},
			info: {},
		},
	];

	async fetchMarkets(params?: Params): Promise<Market[]> {
		return this._markets;
	}

	async fetchBalance(params?: Params): Promise<Balances> {
		return this.balances as any;
	}

	async createMarketOrder(
		symbol: string,
		side: 'buy' | 'sell',
		amount: number,
		price?: number,
		params?: Params
	): Promise<Order> {
		return {
			id: '123',
		} as Order;
	}

	async fetchOHLCV(
		symbol: string,
		timeframe?: string,
		since?: number,
		limit?: number,
		params?: Params
	): Promise<OHLCV[]> {
		switch (symbol) {
			case 'BTC/USDT':
				return [[0, 3, 0, 0, 0, 0]];
			case 'BTC/GBP':
				return [[0, 2, 0, 0, 0, 0]];
			case 'GBP/USDT':
				return [[0, 1.5, 0, 0, 0, 0]];
		}
		return null;
	}
}
export class MockExchangeService extends ExchangeService {
	exchanges: MockExchange[] = [
		new MockExchange({ id: 'coinbasepro' }),
		new MockExchange({ id: 'binance' }),
	];
	async onModuleInit(): Promise<void> {}

	trade = jest.fn(super.trade);
}
