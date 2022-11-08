import { Module } from '@nestjs/common';
import { PotModule } from 'module/pot/pot.module';
import { ReceiverModule } from 'module/receiver/receiver.module';
import { SharedModule } from 'module/shared.module';
import { LnUrlHandlerModule } from '../lnurl-handler/lnurl-handler.module';
import { LnUrlModule } from '../lnurl.module';
import { LightningAddressController } from './lightning-address.controller';

@Module({
	imports: [
		SharedModule,
		PotModule,
		LnUrlModule,
		ReceiverModule,
		LnUrlHandlerModule,
	],
	controllers: [LightningAddressController],
	exports: [],
	providers: [],
})
export class LightningAddressModule {}
