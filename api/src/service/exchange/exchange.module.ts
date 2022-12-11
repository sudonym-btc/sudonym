import { Module } from '@nestjs/common';
import { BalanceModule } from './balance.module';
import { ExchangeService } from './exchange.service';

@Module({
	imports: [BalanceModule],
	controllers: [],
	providers: [ExchangeService],
	exports: [ExchangeService],
})
export class ExchangeModule {}
