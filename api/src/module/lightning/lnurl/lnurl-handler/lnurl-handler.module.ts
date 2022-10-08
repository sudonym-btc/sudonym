import { Module } from '@nestjs/common';
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
		PotModule,
		ReceiverModule,
		SenderModule,
		TransactionModule,
		LnUrlModule,
	],
	controllers: [LnUrlHandlerController],
	exports: [LnUrlHandlerService],
	providers: [LnUrlHandlerService],
})
export class LnUrlHandlerModule {}
