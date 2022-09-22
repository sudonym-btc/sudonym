import { Module } from '@nestjs/common';
import { ReceiverModule } from 'module/receiver/receiver.module';
import { TransactionModule } from 'module/transaction/transaction.module';
import { LightningNodeModule } from '../lightning-node/lightning-node.module';
import { BitcoinEvents } from './bitcoin-events';
import { BitcoinListener } from './bitcoin-listener';
import { LightningEvents } from './lightning-events';
import { LightningListener } from './lightning-listener';

@Module({
	imports: [LightningNodeModule, TransactionModule, ReceiverModule],
	controllers: [],
	providers: [
		LightningListener,
		BitcoinListener,
		LightningEvents,
		BitcoinEvents,
	],
	exports: [],
})
export class TransactionListenerModule {}
