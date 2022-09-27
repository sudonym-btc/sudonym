import { Controller } from '@nestjs/common';
import { BaseController } from '../base.controller';
import { BoltCard } from './bolt-card.model';
import { BoltCardService } from './bolt-card.service';

@Controller('bolt-card')
export class BoltCardController extends BaseController(
	BoltCardService,
	BoltCard
) {}
