import { Inject, Injectable } from '@nestjs/common';
import { CurrencyResponse } from '@sudonym/models';

@Injectable()
export class CurrencyService {
	convert(from, to, amount, time?): Promise<CurrencyResponse> {
		throw Error('Unimplementd');
	}
}

@Injectable()
export class MockCurrencyService extends CurrencyService {
	rates = [
		['USD', 'BTC', 20000],
		['USD', 'GBP', 1.2],
	];

	async convert(from, to, amount, time?) {
		if (from == to) return new CurrencyResponse(amount);
		const rate = this.rates.find((r) => {
			return (r[0] == from && r[1] == to) || (r[1] == from && r[0] == to);
		});

		const currencyResponse = new CurrencyResponse(
			rate[0] == from
				? amount / (rate[2] as any)
				: amount * (rate[2] as any)
		);
		return currencyResponse;
	}
}
