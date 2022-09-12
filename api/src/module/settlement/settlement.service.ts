import { Injectable } from '@nestjs/common';
import { BaseService } from '../base.service';
import { Settlement } from './settlement.model';

@Injectable()
export class SettlementService extends BaseService(Settlement) {}
