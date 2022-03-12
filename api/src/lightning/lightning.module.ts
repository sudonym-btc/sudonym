import { Module } from '@nestjs/common';
import { BitcoinListener } from './bitcoin-listener';
import { LightningService } from './lightning.service';

@Module({
  imports: [],
  controllers: [],
  exports: [LightningService],
  providers: [BitcoinListener, LightningService],
})
export class LightningModule { }