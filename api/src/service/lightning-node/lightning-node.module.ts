import { Module } from '@nestjs/common';
import { LightningNodeService } from './lightning-node.service';

@Module({
  imports: [],
  controllers: [],
  exports: [LightningNodeService],
  providers: [LightningNodeService],
})
export class LightningNodeModule { }