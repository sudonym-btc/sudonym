import { Module } from '@nestjs/common';
import { PotModule } from 'module/pot/pot.module';
import { SettlementModule } from 'module/settlement/settlement.module';
import { TransactionModule } from 'module/transaction/transaction.module';
import { ExchangeSettler } from './exchange-settler';

@Module({
	imports: [TransactionModule, PotModule, SettlementModule],
	controllers: [],
	providers: [ExchangeSettler],
	exports: [],
})
export class ExchangeSettlerModule {}
