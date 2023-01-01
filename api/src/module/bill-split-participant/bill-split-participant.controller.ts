import { Controller } from '@nestjs/common';
import { BaseController } from '../base.controller';
import { BillSplitParticipant } from './bill-split-participant.model';
import { BillSplitParticipantService } from './bill-split-participant.service';

@Controller('billSplitParticipant')
export class BillSplitParticipantController extends BaseController({
	service: BillSplitParticipantService,
	model: BillSplitParticipant,
	create: {
		validator: {
			whitelist: true,
		},
	},
	update: {
		validator: {
			whitelist: true,
		},
	},
}) {}
