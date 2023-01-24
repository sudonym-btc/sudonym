import { Controller } from '@nestjs/common';
import { BaseController } from '../base.controller';
import { TransactionTag } from './transaction-tag.model';
import { TransactionTagService } from './transaction-tag.service';

@Controller('transactionTag')
export class TransactionTagController extends BaseController({
	service: TransactionTagService,
	model: TransactionTag,
	create: {
		auth: true,
		validator: {
			whitelist: true,
		},
	},
	update: false,
}) {}
