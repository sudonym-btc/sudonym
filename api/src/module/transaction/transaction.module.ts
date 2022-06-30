import { Module } from '@nestjs/common';
import { SharedModule } from '../shared.module';
import { TransactionController } from './transaction.controller';
import { Transaction } from './transaction.model';
import { TransactionService } from './transaction.service';

@Module({
  imports: [SharedModule],
  controllers: [TransactionController],
  providers: [TransactionService, {
    provide: Transaction,
    useValue: Transaction,
  },],
  exports: [TransactionService],
})
export class TransactionModule { }