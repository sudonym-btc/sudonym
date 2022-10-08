import { Module } from '@nestjs/common';
import { LightningNodeModule } from 'service/lightning-node/lightning-node.module';
import { LightningAddressModule } from './lnurl/lightning-address/lightning-address.module';
import { LnUrlModule } from './lnurl/lnurl.module';

@Module({
	imports: [LightningNodeModule, LnUrlModule, LightningAddressModule],
	controllers: [],
	exports: [],
	providers: [],
})
export class LightningModule {}
