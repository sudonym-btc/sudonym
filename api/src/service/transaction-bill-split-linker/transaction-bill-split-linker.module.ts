import { Module } from '@nestjs/common';
import { BillSplitParticipantModule } from 'module/bill-split-participant/bill-split-participant.module';
import { BillSplitModule } from 'module/bill-split/bill-split.module';
import { CurrencyModule } from 'module/currency/currency.module';
import { TransactionModule } from 'module/transaction/transaction.module';
import { TransactionBillSplitLinkerService } from './transaction-bill-split-linker.service';

@Module({
	imports: [
		TransactionModule,
		BillSplitModule,
		BillSplitParticipantModule,
		CurrencyModule,
	],
	controllers: [],
	providers: [TransactionBillSplitLinkerService],
	exports: [],
})
export class TransactionBillSplitLinkerModule {}
