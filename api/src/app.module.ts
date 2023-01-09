import { MiddlewareConsumer, Module, RequestMethod } from '@nestjs/common';
import * as Sentry from '@sentry/node';
import { ProfilingIntegration } from '@sentry/profiling-node';
import { Integrations } from '@sentry/tracing';
import { getConfig } from 'config/config';
import { ConfigModule } from 'config/config.module';
import { BillSplitModule } from 'module/bill-split/bill-split.module';
import { BoltCardModule } from 'module/bolt-card/bolt-card.module';
import { ContactModule } from 'module/contact/contact.module';
import { PotUserModule } from 'module/pot-user/pot-user.module';
import { SenderModule } from 'module/sender/sender.module';
import { BalanceModule } from 'service/exchange/balance.module';
import { ExchangeSettlerModule } from 'service/exchange/exchange-settler.module';
import { ExchangeModule } from 'service/exchange/exchange.module';
import { FirebaseNotificationModule } from 'service/firebase-notification/firebase-notification.module';
import { SentryModule } from 'service/sentry/sentry.module';
import { TransactionBillSplitLinkerModule } from 'service/transaction-bill-split-linker/transaction-bill-split-linker.module';
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
		SentryModule.forRoot({
			dsn: 'REDACTED_SENTRY_DSN',
			environment: getConfig().env,
			integrations: [
				new Integrations.Express(),
				new ProfilingIntegration(),
			],
			// Set tracesSampleRate to 1.0 to capture 100%
			// of transactions for performance monitoring.
			// We recommend adjusting this value in production
			tracesSampleRate: 1.0,
			profilesSampleRate: 1.0,
		}),
		ConfigModule,
		TransactionListenerModule,
		BalanceModule,
		ExchangeModule,
		ExchangeSettlerModule,
		TransactionBillSplitLinkerModule,
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
		BillSplitModule,
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
export class AppModule {
	configure(consumer: MiddlewareConsumer): void {
		consumer.apply(Sentry.Handlers.requestHandler()).forRoutes({
			path: '*',
			method: RequestMethod.ALL,
		});
	}
}
