import { Module } from '@nestjs/common';
import { LightningNodeModule } from 'service/lightning-node/lightning-node.module';
import { CurrencyModule } from '../currency/currency.module';
import { LnUrlModule } from '../lightning/lnurl/lnurl.module';
import { SharedModule } from '../shared.module';
import { SenderController } from './sender.controller';
import { Sender } from './sender.model';
import { SenderService } from './sender.service';

@Module({
	imports: [SharedModule, CurrencyModule, LightningNodeModule, LnUrlModule],
	controllers: [SenderController],
	providers: [
		SenderService,
		{
			provide: Sender,
			useValue: Sender,
		},
	],
	exports: [SenderService],
})
export class SenderModule {}
