import { forwardRef, Module } from '@nestjs/common';
import { LightningNodeModule } from 'service/lightning-node/lightning-node.module';
import { BalanceService } from './balance.service';
import { ExchangeModule } from './exchange.module';

@Module({
	imports: [forwardRef(() => ExchangeModule), LightningNodeModule],
	controllers: [],
	providers: [BalanceService],
	exports: [BalanceService],
})
export class BalanceModule {}
