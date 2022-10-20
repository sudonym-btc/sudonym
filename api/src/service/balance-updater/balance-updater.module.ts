import { Module } from '@nestjs/common';
import { CurrencyModule } from 'module/currency/currency.module';
import { PotModule } from 'module/pot/pot.module';
import { TransactionModule } from 'module/transaction/transaction.module';
import { UserDeviceModule } from 'module/user-device/user-device.module';
import { BalanceUpdaterService } from './balance-updater.service';

@Module({
	imports: [CurrencyModule, PotModule, TransactionModule, UserDeviceModule],
	controllers: [],
	exports: [BalanceUpdaterService],
	providers: [BalanceUpdaterService],
})
export class BalanceUpdaterModule {}
