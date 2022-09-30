import { Module } from '@nestjs/common';
import { getConfig } from 'config/config';
import { ExchangeModule } from 'service/exchange/exchange.module';
import { SharedModule } from '../shared.module';
import { CurrencyController } from './currency.controller';
import { CurrencyService, MockCurrencyService } from './currency.service';

@Module({
	imports: [SharedModule, ExchangeModule],
	controllers: [CurrencyController],
	providers: [
		{
			provide: CurrencyService,
			useClass: ['mock', 'development'].includes(getConfig().env)
				? MockCurrencyService
				: CurrencyService,
		},
	],
	exports: [CurrencyService],
})
export class CurrencyModule {}
