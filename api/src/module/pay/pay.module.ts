import { Module } from '@nestjs/common';
import { LightningModule } from 'src/module/lightning/lightning.module';
import { TransactionModule } from '../transaction/transaction.module';
import { PayController } from './pay.controller';
import { PayService } from './pay.service';

@Module({
  imports: [LightningModule, TransactionModule],
  controllers: [PayController],
  providers: [PayService],
  exports: [PayService],
})
export class PayModule { }