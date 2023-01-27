import { Module } from '@nestjs/common';
import { PotModule } from 'module/pot/pot.module';
import { TransactionTagModule } from 'module/transaction-tag/transaction-tag.module';
import { SharedModule } from '../shared.module';
import { TransactionController } from './transaction.controller';
import { Transaction } from './transaction.model';
import { TransactionService } from './transaction.service';

@Module({
	imports: [SharedModule, PotModule, TransactionTagModule],
	controllers: [TransactionController],
	providers: [
		TransactionService,
		{
			provide: Transaction,
			useValue: Transaction,
		},
	],
	exports: [TransactionService],
})
export class TransactionModule {}
