import { Module } from '@nestjs/common';
import { EventsModule } from 'module/events/events.module';
import { ReceiverModule } from 'module/receiver/receiver.module';
import { TransactionModule } from 'module/transaction/transaction.module';
import { LightningNodeModule } from '../lightning-node/lightning-node.module';
import { BitcoinEvents } from './bitcoin-events';
import { BitcoinListener } from './bitcoin-listener';
import { EventBroadcaster } from './event-broadcaster';
import { LightningEvents } from './lightning-events';
import { LightningListener } from './lightning-listener';

@Module({
	imports: [LightningNodeModule, TransactionModule, ReceiverModule, EventsModule],
	controllers: [],
	providers: [
		LightningListener,
		BitcoinListener,
		LightningEvents,
		BitcoinEvents,
		EventBroadcaster
	],
	exports: [],
})
export class TransactionListenerModule { }
