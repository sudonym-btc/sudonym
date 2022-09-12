import { Module } from '@nestjs/common';
import { CurrencyModule } from 'src/module/currency/currency.module';
import { PotModule } from 'src/module/pot/pot.module';
import { TransactionModule } from 'src/module/transaction/transaction.module';
import { BalanceUpdaterService } from './balance-updater.service';

@Module({
	imports: [CurrencyModule, PotModule, TransactionModule],
	controllers: [],
	exports: [BalanceUpdaterService],
	providers: [BalanceUpdaterService],
})
export class BalanceUpdaterModule { }