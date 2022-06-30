import { Injectable } from '@nestjs/common';
import { BaseService } from '../base.service';
import { TransactionSettlement } from './transaction-settlement.model';

@Injectable()
export class TransactionSettlementService extends BaseService(TransactionSettlement) {

}