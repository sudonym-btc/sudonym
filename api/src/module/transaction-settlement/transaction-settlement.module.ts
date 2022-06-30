import { Module } from '@nestjs/common';
import { SharedModule } from '../shared.module';
import { TransactionSettlement } from './transaction-settlement.model';
import { TransactionSettlementService } from './transaction-settlement.service';

@Module({
  imports: [SharedModule],
  controllers: [],
  providers: [TransactionSettlementService, {
    provide: TransactionSettlement,
    useValue: TransactionSettlement,
  },],
  exports: [TransactionSettlementService],
})
export class TransactionSettlementModule { }