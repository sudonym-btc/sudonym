import { Module } from '@nestjs/common';
import { SettlementModule } from 'module/settlement/settlement.module';
import { ExchangeService } from './exchange.service';

@Module({
	imports: [SettlementModule],
	controllers: [],
	providers: [ExchangeService],
	exports: [ExchangeService],
})
export class ExchangeModule {}
