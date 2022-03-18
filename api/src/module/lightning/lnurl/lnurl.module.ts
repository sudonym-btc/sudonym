import { Module } from '@nestjs/common';
import { LnUrlController } from './lnurl.controller';
import { LnUrlService } from './lnurl.service';

@Module({
  imports: [],
  controllers: [LnUrlController],
  exports: [LnUrlService],
  providers: [LnUrlService],
})
export class LnUrlModule {


}