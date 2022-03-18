import { Module } from '@nestjs/common';
import { TransactionController } from './transaction.controller';
import { Transaction } from './transaction.model';
import { TransactionService } from './transaction.service';

@Module({
  imports: [],
  controllers: [TransactionController],
  providers: [TransactionService, {
    provide: Transaction,
    useValue: Transaction,
  },],
  exports: [TransactionService],
})
export class TransactionModule { }