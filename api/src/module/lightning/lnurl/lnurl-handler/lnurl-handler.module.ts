import { Module } from '@nestjs/common';
import { ActionModule } from 'module/action/action.module';
import { CurrencyModule } from 'module/currency/currency.module';
import { PotModule } from 'module/pot/pot.module';
import { ReceiverModule } from 'module/receiver/receiver.module';
import { SenderModule } from 'module/sender/sender.module';
import { SharedModule } from 'module/shared.module';
import { TransactionModule } from 'module/transaction/transaction.module';
import { LnUrlModule } from '../lnurl.module';
import { LnUrlHandlerController } from './lnurl-handler.controller';
import { LnUrlHandlerService } from './lnurl-handler.service';

@Module({
	imports: [
		SharedModule,
		CurrencyModule,
		PotModule,
		ReceiverModule,
		SenderModule,
		TransactionModule,
		LnUrlModule,
		ActionModule,
	],
	controllers: [LnUrlHandlerController],
	exports: [LnUrlHandlerService],
	providers: [LnUrlHandlerService],
})
export class LnUrlHandlerModule {}
