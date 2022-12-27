import { Injectable } from '@nestjs/common';
import { BaseService } from '../base.service';
import { BillSplit } from './bill-split.model';

@Injectable()
export class BillSplitService extends BaseService(BillSplit) {}
