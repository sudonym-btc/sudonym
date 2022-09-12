import { Controller, Inject } from '@nestjs/common';
import { Transaction } from '@sudonym/models';
import { BaseController } from '../base.controller';
import { TransactionService } from './transaction.service';

@Controller('transaction')
export class TransactionController extends BaseController(
	TransactionService,
	Transaction
) {
}