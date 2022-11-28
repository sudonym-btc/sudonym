import { Module } from '@nestjs/common';
import { PotModule } from 'module/pot/pot.module';
import { SettlementModule } from 'module/settlement/settlement.module';
import { TransactionModule } from 'module/transaction/transaction.module';
import { LightningNodeModule } from 'service/lightning-node/lightning-node.module';
import { ExchangeSettlerService } from './exchange-settler.service';
import { ExchangeModule } from './exchange.module';

@Module({
	imports: [
		LightningNodeModule,
		TransactionModule,
		PotModule,
		SettlementModule,
		ExchangeModule,
	],
	controllers: [],
	providers: [ExchangeSettlerService],
	exports: [],
})
export class ExchangeSettlerModule {}
