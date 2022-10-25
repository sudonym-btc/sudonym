import { CacheTTL, Controller, Get, Header, Inject, Query } from '@nestjs/common';
import { CurrencyService } from './currency.service';

@Controller('currency')
export class CurrencyController {
	@Inject(CurrencyService) service: CurrencyService;

	@Get('')
	@CacheTTL(60)
	@Header('Cache-Control', 'max-age=60')
	convert(
		@Query('fromCurrency') from,
		@Query('toCurrency') to,
		@Query('amount') amount,
		@Query('time') time
	) {
		return this.service.convert(
			from,
			to,
			amount,
			time ? new Date(time) : new Date()
		);
	}
}
