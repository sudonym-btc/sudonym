import { Module } from '@nestjs/common';
import { LightningNodeModule } from 'src/service/lightning-node/lightning-node.module';
import { CurrencyModule } from '../currency/currency.module';
import { LnUrlHandlerModule } from '../lightning/lnurl/lnurl-handler/lnurl-handler.module';
import { SharedModule } from '../shared.module';
import { TransactionModule } from '../transaction/transaction.module';
import { ActionController } from './action.controller';
import { ActionService } from './action.service';
import { AddressParser } from './address-parser/address-parser';

@Module({
	imports: [
		SharedModule,
		CurrencyModule,
		LnUrlHandlerModule,
		LightningNodeModule,
		TransactionModule,
	],
	controllers: [ActionController],
	providers: [ActionService, AddressParser],
	exports: [ActionService],
})
export class ActionModule {}
