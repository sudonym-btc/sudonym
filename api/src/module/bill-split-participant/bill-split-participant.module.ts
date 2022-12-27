import { Module } from '@nestjs/common';
import { SharedModule } from '../shared.module';
import { BillSplitParticipantController } from './bill-split-participant.controller';
import { BillSplitParticipant } from './bill-split-participant.model';
import { BillSplitParticipantService } from './bill-split-participant.service';

@Module({
	imports: [SharedModule],
	controllers: [BillSplitParticipantController],
	providers: [
		BillSplitParticipantService,
		{
			provide: BillSplitParticipant,
			useValue: BillSplitParticipant,
		},
	],
	exports: [BillSplitParticipantService],
})
export class BillSplitParticipantModule {}
