import { Module } from '@nestjs/common';
import { ReceiverModule } from 'module/receiver/receiver.module';
import { LightningNodeModule } from 'service/lightning-node/lightning-node.module';
import { CurrencyModule } from '../currency/currency.module';
import { LnUrlHandlerModule } from '../lightning/lnurl/lnurl-handler/lnurl-handler.module';
import { SharedModule } from '../shared.module';
import { TransactionModule } from '../transaction/transaction.module';
import { ActionController } from './action.controller';
import { ActionService } from './action.service';
import { AddressParserModule } from './address-parser/address-parser.module';

@Module({
	imports: [
		SharedModule,
		CurrencyModule,
		LnUrlHandlerModule,
		LightningNodeModule,
		TransactionModule,
		ReceiverModule,
		AddressParserModule,
	],
	controllers: [ActionController],
	providers: [ActionService],
	exports: [ActionService],
})
export class ActionModule {}
