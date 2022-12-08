import { Module } from '@nestjs/common';
import { ConfigModule } from 'config/config.module';
import { BoltCardModule } from 'module/bolt-card/bolt-card.module';
import { ContactModule } from 'module/contact/contact.module';
import { PotUserModule } from 'module/pot-user/pot-user.module';
import { SenderModule } from 'module/sender/sender.module';
import { FirebaseNotificationModule } from 'service/firebase-notification/firebase-notification.module';
import { TransactionContactLinkerModule } from 'service/transaction-contact-linker/transaction-contact-linker.module';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { DatabaseModule } from './database/database.module';
import { ActionModule } from './module/action/action.module';
import { AuthModule } from './module/auth/auth.module';
import { CurrencyModule } from './module/currency/currency.module';
import { EventsModule } from './module/events/events.module';
import { LightningModule } from './module/lightning/lightning.module';
import { PotModule } from './module/pot/pot.module';
import { ReceiverModule } from './module/receiver/receiver.module';
import { TransactionModule } from './module/transaction/transaction.module';
import { UserDeviceModule } from './module/user-device/user-device.module';
import { UserModule } from './module/user/user.module';
import { BalanceUpdaterModule } from './service/balance-updater/balance-updater.module';
import { TransactionListenerModule } from './service/transaction-listener/transaction-listener.module';

@Module({
	imports: [
		ConfigModule,
		TransactionListenerModule,
		// ExchangeSettlerModule,
		TransactionContactLinkerModule,
		DatabaseModule,
		CurrencyModule,
		LightningModule,
		EventsModule,
		AuthModule,
		UserModule,
		ContactModule,
		UserDeviceModule,
		PotModule,
		PotUserModule,
		ActionModule,
		BalanceUpdaterModule,
		FirebaseNotificationModule,
		ReceiverModule,
		SenderModule,
		BoltCardModule,
		TransactionModule,
	],
	controllers: [AppController],
	providers: [AppService],
})
export class AppModule {}
