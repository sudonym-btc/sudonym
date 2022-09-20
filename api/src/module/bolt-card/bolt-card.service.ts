import { Inject, Injectable } from '@nestjs/common';
import { BaseService } from '../base.service';
import { BoltCard } from './bolt-card.model';

@Injectable()
export class BoltCardService extends BaseService(BoltCard) {}
