import { Module } from '@nestjs/common';
import { AuthModule } from 'module/auth/auth.module';
import { CurrencyModule } from 'module/currency/currency.module';
import { PotModule } from 'module/pot/pot.module';
import { TransactionModule } from 'module/transaction/transaction.module';
import { BalanceUpdaterService } from './balance-updater.service';

@Module({
	imports: [AuthModule, CurrencyModule, PotModule, TransactionModule],
	controllers: [],
	exports: [BalanceUpdaterService],
	providers: [BalanceUpdaterService],
})
export class BalanceUpdaterModule {}
