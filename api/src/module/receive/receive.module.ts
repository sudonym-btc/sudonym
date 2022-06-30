import { Module } from '@nestjs/common';
import { LightningNodeModule } from 'src/service/lightning-node/lightning-node.module';
import { LnUrlModule } from '../lightning/lnurl/lnurl.module';
import { SharedModule } from '../shared.module';
import { ReceiveController } from './receive.controller';
import { ReceiveService } from './receive.service';
import { Receiver } from './receiver.model';

@Module({
  imports: [SharedModule, LightningNodeModule, LnUrlModule],
  controllers: [ReceiveController],
  providers: [ReceiveService, {
    provide: Receiver,
    useValue: Receiver,
  }],
  exports: [ReceiveService],
})
export class ReceiveModule { }