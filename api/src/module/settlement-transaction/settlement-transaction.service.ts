import { Injectable } from '@nestjs/common';
import { BaseService } from '../base.service';
import { SettlementTransaction } from './settlement-transaction.model';

@Injectable()
export class SettlementTransactionService extends BaseService(
	SettlementTransaction
) {}
