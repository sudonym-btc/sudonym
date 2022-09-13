import { Module } from '@nestjs/common';
import { SharedModule } from 'module/shared.module';
import { LightningAddressController } from './lightning-address.controller';
import { LnUrlController } from './lnurl.controller';
import { LnUrl } from './lnurl.model';
import { LnUrlService } from './lnurl.service';

@Module({
	imports: [SharedModule],
	controllers: [LnUrlController, LightningAddressController],
	exports: [LnUrlService],
	providers: [
		{
			provide: LnUrl,
			useValue: LnUrl,
		},
		LnUrlService,
	],
})
export class LnUrlModule {}
