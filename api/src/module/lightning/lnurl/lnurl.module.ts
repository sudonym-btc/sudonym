import { Module } from '@nestjs/common';
import { SharedModule } from 'module/shared.module';
import { LnUrlController } from './lnurl.controller';
import { LnUrl } from './lnurl.model';
import { LnUrlService } from './lnurl.service';

@Module({
	imports: [SharedModule],
	controllers: [LnUrlController],
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
