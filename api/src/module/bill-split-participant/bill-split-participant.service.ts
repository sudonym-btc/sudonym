import { Injectable } from '@nestjs/common';
import { BaseService } from '../base.service';
import { BillSplitParticipant } from './bill-split-participant.model';

@Injectable()
export class BillSplitParticipantService extends BaseService(
	BillSplitParticipant
) {}
