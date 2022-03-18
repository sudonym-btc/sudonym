import { Module } from '@nestjs/common';
import { LightningModule } from 'src/module/lightning/lightning.module';
import { LnUrlModule } from '../lightning/lnurl/lnurl.module';
import { ReceiveController } from './receive.controller';
import { ReceiveService } from './receive.service';

@Module({
  imports: [LightningModule, LnUrlModule],
  controllers: [ReceiveController],
  providers: [ReceiveService],
  exports: [ReceiveService],
})
export class ReceiveModule { }