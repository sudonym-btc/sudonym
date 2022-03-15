import { Module } from '@nestjs/common';
import { LightningModule } from 'src/lightning/lightning.module';
import { ReceiveController } from './receive.controller';
import { ReceiveService } from './receive.service';

@Module({
  imports: [LightningModule],
  controllers: [ReceiveController],
  providers: [ReceiveService],
  exports: [ReceiveService],
})
export class ReceiveModule { }