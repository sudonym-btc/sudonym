import { Module } from '@nestjs/common';
import { ReceiveModule } from 'src/module/receive/receive.module';
import { SharedModule } from 'src/module/shared.module';
import { LnUrlModule } from '../lnurl.module';
import { LnUrlHandlerController } from './lnurl-handler.controller';
import { LnUrlHandlerService } from './lnurl-handler.service';

@Module({
	imports: [SharedModule, ReceiveModule, LnUrlModule],
	controllers: [LnUrlHandlerController],
	exports: [LnUrlHandlerService],
	providers: [LnUrlHandlerService],
})
export class LnUrlHandlerModule {


}