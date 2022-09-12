import { Injectable } from '@nestjs/common';
import { BaseService } from '../base.service';
import { Transaction } from './transaction.model';

@Injectable()
export class TransactionService extends BaseService(Transaction) {}
