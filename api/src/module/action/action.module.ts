import { Module } from '@nestjs/common';
import { ReceiverModule } from 'module/receiver/receiver.module';
import { LightningNodeModule } from 'service/lightning-node/lightning-node.module';
import { CurrencyModule } from '../currency/currency.module';
import { SharedModule } from '../shared.module';
import { TransactionModule } from '../transaction/transaction.module';
import { ActionController } from './action.controller';
import { ActionService } from './action.service';
import { AddressParser } from './address-parser.service';
import { LightningOperationsService } from './lightning-operations.service';
import { LnurlOperationsService } from './lnurl-operations.service';
import { OnchainOperationsService } from './onchain-operations.service';

@Module({
	imports: [
		SharedModule,
		CurrencyModule,
		LightningNodeModule,
		TransactionModule,
		ReceiverModule,
	],
	controllers: [ActionController],
	providers: [
		ActionService,
		AddressParser,
		LightningOperationsService,
		LnurlOperationsService,
		OnchainOperationsService,
	],
	exports: [ActionService, AddressParser],
})
export class ActionModule {}
