import { Controller } from '@nestjs/common';
import { BaseController } from '../base.controller';
import { BillSplit } from './bill-split.model';
import { BillSplitService } from './bill-split.service';

@Controller('billSplit')
export class BillSplitController extends BaseController({
	service: BillSplitService,
	model: BillSplit,
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
// todo: look into GBP USD conversion error where £3 equallyed 5 dollars and then £4.10 equalled 5 dollars
