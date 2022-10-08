import { Module } from '@nestjs/common';
import { PotModule } from 'module/pot/pot.module';
import { SettlementModule } from 'module/settlement/settlement.module';
import { TransactionModule } from 'module/transaction/transaction.module';
import { ExchangeService } from './exchange.service';

@Module({
	imports: [TransactionModule, PotModule, SettlementModule],
	controllers: [],
	providers: [ExchangeService],
	exports: [],
})
export class ExchangeSettlerModule {}
