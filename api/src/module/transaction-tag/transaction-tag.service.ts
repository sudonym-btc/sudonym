import { Injectable } from '@nestjs/common';
import { BaseService } from '../base.service';
import { TransactionTag } from './transaction-tag.model';

@Injectable()
export class TransactionTagService extends BaseService(TransactionTag) {}
