import {
	CacheTTL,
	Controller,
	Get,
	Header,
	Inject,
	Query,
	Res,
} from '@nestjs/common';
import { CurrencyService } from './currency.service';

@Controller('currency')
export class CurrencyController {
	@Inject(CurrencyService) service: CurrencyService;

	@Get('')
	@CacheTTL(60)
	@Header('Cache-Control', 'max-age=60')
	async convert(
		@Query('fromCurrency') from,
		@Query('toCurrency') to,
		@Query('amount') amount,
		@Query('time') time,
		@Res({ passthrough: true }) response
	) {
		if (!time) {
			response.set('Cache-Control', 'public, max-age=60');
		} else {
			response.set('Cache-Control', 'public, max-age=31536000');
		}
		return this.service.convert(
			from,
			to,
			amount,
			time ? new Date(time) : null
		);
	}
}
