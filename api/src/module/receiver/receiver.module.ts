import { Module } from '@nestjs/common';
import { LightningNodeModule } from 'service/lightning-node/lightning-node.module';
import { CurrencyModule } from '../currency/currency.module';
import { LnUrlModule } from '../lightning/lnurl/lnurl.module';
import { SharedModule } from '../shared.module';
import { ReceiverController } from './receiver.controller';
import { ReceiverService } from './receiver.service';
import { Receiver } from './receiver.model';
import { PotModule } from 'module/pot/pot.module';

@Module({
	imports: [SharedModule, CurrencyModule, PotModule, LightningNodeModule, LnUrlModule],
	controllers: [ReceiverController],
	providers: [
		ReceiverService,
		{
			provide: Receiver,
			useValue: Receiver,
		},
	],
	exports: [ReceiverService],
})
export class ReceiverModule {}
