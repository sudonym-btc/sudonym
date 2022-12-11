import { Balances, Exchange, Market, OHLCV, Order, Params, Ticker } from 'ccxt';
import { ExchangeService } from 'service/exchange/exchange';

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

	async fetchTicker(symbol: string, params?: Params): Promise<Ticker> {
		switch (symbol) {
			case 'BTC/USDT':
				return {
					symbol: 'BTC/USDT',
					bid: 3,
					ask: 3,
					info: {},
					timestamp: null,
					datetime: null,
					high: 3,
					low: 3,
				};
			case 'BTC/GBP':
				return {
					symbol: 'BTC/GBP',
					bid: 2,
					ask: 2,
					info: {},
					timestamp: null,
					datetime: null,
					high: 2,
					low: 2,
				};
			case 'GBP/USDT':
				return {
					symbol: 'GBP/USDT',
					bid: 1.5,
					ask: 1.5,
					info: {},
					timestamp: null,
					datetime: null,
					high: 1.5,
					low: 1.5,
				};
		}
		return null;
	}

	async fetchOHLCV(
		symbol: string,
		timeframe?: string,
		since?: number,
		limit?: number,
		params?: Params
	): Promise<OHLCV[]> {
		// UTC timestamp in milliseconds, integer
		//     4235.4,        // (O)pen price, float
		//     4240.6,        // (H)ighest price, float
		//     4230.0,        // (L)owest price, float
		//     4230.7,        // (C)losing price, float
		//     37.72941911    // (V)olume float (usually in terms of the base currency, the exchanges docstring may list whether quote or base units are used)
		// ],
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
