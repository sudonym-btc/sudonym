import { Module } from '@nestjs/common';
import { CurrencyModule } from 'module/currency/currency.module';
import { PotModule } from 'module/pot/pot.module';
import { TransactionModule } from 'module/transaction/transaction.module';
import { RoundupService } from './roundup.service';

@Module({
	imports: [CurrencyModule, PotModule, TransactionModule],
	controllers: [],
	exports: [RoundupService],
	providers: [RoundupService],
})
export class RoundupModule {}
