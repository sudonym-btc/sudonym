import { Inject, Injectable } from '@nestjs/common';
import { BaseService } from '../base.service';
import { Pot } from './pot.model';

@Injectable()
export class PotService extends BaseService(Pot) {}
