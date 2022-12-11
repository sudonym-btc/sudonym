import { CacheModule, forwardRef, Module } from '@nestjs/common';
import { BalanceModule } from './balance.module';
import { ExchangeService } from './exchange.service';

@Module({
	imports: [forwardRef(() => BalanceModule), CacheModule.register()],
	controllers: [],
	providers: [ExchangeService],
	exports: [ExchangeService],
})
export class ExchangeModule {}
