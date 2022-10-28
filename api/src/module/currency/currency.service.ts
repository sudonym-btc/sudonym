import { Inject, Injectable } from '@nestjs/common';
import { CurrencyResponse, SATOSHIS } from '@sudonym/models';
import { ExchangeService } from 'service/exchange/exchange.service';

@Injectable()
export class CurrencyService {
	@Inject() exchangeService: ExchangeService;

	async convert(
		from,
		to,
		amount = 1,
		time?: Date
	): Promise<CurrencyResponse> {
		return new CurrencyResponse(
			amount == 0
				? 0
				: (await this.exchangeService.fetchPriceAtTime(
					from,
					to,
					time
				)) * amount
		);
	}

	format(amount: number, currency: string) {
		if (currency == "BTC") {
			if (amount > 0.1) {
				return `${amount.toPrecision(4)} BTC`;
			} else {
				return `${new Intl.NumberFormat('en-US').format(amount * SATOSHIS)} sats`;
			}
		}
		// Create our number formatter.
		const formatter = new Intl.NumberFormat('en-US', {
			style: 'currency',
			currency,

			// These options are needed to round to whole numbers if that's what you want.
			//minimumFractionDigits: 0, // (this suffices for whole numbers, but will print 2500.10 as $2,500.1)
			//maximumFractionDigits: 0, // (causes 2500.99 to be printed as $2,501)
		});

		return formatter.format(amount);
	}
}

@Injectable()
export class MockCurrencyService extends CurrencyService {
	rates = [
		['USD', 'BTC', 20000],
		['USD', 'GBP', 1.2],
	];

	async convert(from = 'BTC', to = 'BTC', amount = 0, time?) {
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
