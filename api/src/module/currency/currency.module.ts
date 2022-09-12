import { Module } from '@nestjs/common';
import { getConfig } from 'src/config/config';
import { SharedModule } from '../shared.module';
import { CurrencyController } from './currency.controller';
import { CurrencyService, MockCurrencyService } from './currency.service';

@Module({
	imports: [SharedModule],
	controllers: [CurrencyController],
	providers: [
		{
			provide: CurrencyService,
			useClass:
				getConfig().env == 'development'
					? MockCurrencyService
					: CurrencyService,
		},
	],
	exports: [CurrencyService],
})
export class CurrencyModule {}
