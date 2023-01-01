import { Module } from '@nestjs/common';
import { TransactionModule } from 'module/transaction/transaction.module';
import { BillSplitParticipantModule } from '../bill-split-participant/bill-split-participant.module';
import { SharedModule } from '../shared.module';
import { BillSplitController } from './bill-split.controller';
import { BillSplit } from './bill-split.model';
import { BillSplitService } from './bill-split.service';

@Module({
	imports: [SharedModule, BillSplitParticipantModule, TransactionModule],
	controllers: [BillSplitController],
	providers: [
		BillSplitService,
		{
			provide: BillSplit,
			useValue: BillSplit,
		},
	],
	exports: [BillSplitService],
})
export class BillSplitModule {}
