import { Controller, Get, Inject, Query } from '@nestjs/common';
import { CurrencyService } from './currency.service';

@Controller('currency')
export class CurrencyController {

    @Inject(CurrencyService) service: CurrencyService;

    @Get('')
    convert(@Query('fromCurrency') from, @Query('toCurrency') to, @Query('amount') amount, @Query('time') time) {
    	return this.service.convert(from, to, amount, time);
    }
}