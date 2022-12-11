import { Module } from '@nestjs/common';
import { PotModule } from 'module/pot/pot.module';
import { SettlementModule } from 'module/settlement/settlement.module';
import { BalanceModule } from './balance.module';
import { ExchangeSettlerService } from './exchange-settler.service';
import { ExchangeModule } from './exchange.module';

@Module({
	imports: [SettlementModule, PotModule, ExchangeModule, BalanceModule],
	controllers: [],
	providers: [ExchangeSettlerService],
	exports: [],
})
export class ExchangeSettlerModule {}
