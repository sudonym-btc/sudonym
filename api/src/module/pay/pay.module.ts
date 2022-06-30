import { Module } from '@nestjs/common';
import { LightningNodeModule } from 'src/service/lightning-node/lightning-node.module';
import { SharedModule } from '../shared.module';
import { TransactionModule } from '../transaction/transaction.module';
import { PayController } from './pay.controller';
import { PayService } from './pay.service';

@Module({
  imports: [SharedModule, LightningNodeModule, TransactionModule],
  controllers: [PayController],
  providers: [PayService],
  exports: [PayService],
})
export class PayModule { }