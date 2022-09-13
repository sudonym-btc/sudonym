import { Module } from '@nestjs/common';
import { LightningNodeModule } from 'service/lightning-node/lightning-node.module';
import { CurrencyModule } from '../currency/currency.module';
import { LnUrlModule } from '../lightning/lnurl/lnurl.module';
import { SharedModule } from '../shared.module';
import { ReceiveController } from './receive.controller';
import { ReceiveService } from './receive.service';
import { Receiver } from './receiver.model';

@Module({
	imports: [SharedModule, CurrencyModule, LightningNodeModule, LnUrlModule],
	controllers: [ReceiveController],
	providers: [
		ReceiveService,
		{
			provide: Receiver,
			useValue: Receiver,
		},
	],
	exports: [ReceiveService],
})
export class ReceiveModule {}
