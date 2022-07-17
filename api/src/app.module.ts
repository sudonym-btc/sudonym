import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { DatabaseModule } from './database/database.module';
import { LightningModule } from './module/lightning/lightning.module';
import { AuthModule } from './module/auth/auth.module';
import { PayModule } from './module/pay/pay.module';
import { PotModule } from './module/pot/pot.module';
import { ReceiveModule } from './module/receive/receive.module';
import { UserModule } from './module/user/user.module';
import { EventsModule } from './module/events/events.module';
import { TransactionModule } from './module/transaction/transaction.module';
import { LnUrlModule } from './module/lightning/lnurl/lnurl.module';
import { TransactionListenerModule } from './service/transaction-listener/transaction-listener.module';
import { CurrencyModule } from './module/currency/currency.module';
import { UserDeviceModule } from './module/user-device/user-device.module';
import { BalanceUpdaterModule } from './service/balance-updater/balance-updater.module';

@Module({
  imports: [
    TransactionListenerModule,
    DatabaseModule,
    CurrencyModule,
    LightningModule,
    LnUrlModule,
    EventsModule,
    AuthModule, 
    UserModule,
    UserDeviceModule,
    PotModule,
    PayModule,
    BalanceUpdaterModule,
    ReceiveModule,
    TransactionModule
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule { }