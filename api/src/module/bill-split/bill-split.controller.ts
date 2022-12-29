import { Controller } from '@nestjs/common';
import { BillSplitParticipant } from '@sudonym/models';
import { Type } from 'class-transformer';
import {
	ArrayMaxSize,
	ArrayMinSize,
	IsArray,
	IsNumber,
	IsString,
	ValidateNested,
} from 'class-validator';
import { BaseController } from '../base.controller';
import { BillSplit } from './bill-split.model';
import { BillSplitService } from './bill-split.service';

class CreateBillSplit {
	@IsNumber()
	transactionId: number;

	@IsNumber()
	amount: number;

	@IsString()
	currency: string;

	@IsArray()
	@ValidateNested({ each: true })
	@ArrayMinSize(1)
	@ArrayMaxSize(10)
	@Type(() => CreateBillSplitParticipant)
	BillSplitParticipants: BillSplitParticipant[];
}

class CreateBillSplitParticipant {
	@IsNumber()
	amount: number;
}
@Controller('billSplit')
export class BillSplitController extends BaseController({
	service: BillSplitService,
	model: BillSplit,
	create: {
		input: CreateBillSplit,
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
