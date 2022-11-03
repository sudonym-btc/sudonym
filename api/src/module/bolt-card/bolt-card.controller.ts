import { Controller } from '@nestjs/common';
import { BaseController } from '../base.controller';
import { BoltCard } from './bolt-card.model';
import { BoltCardService } from './bolt-card.service';

@Controller('boltCard')
export class BoltCardController extends BaseController({
	service: BoltCardService,
	model: BoltCard,
}) {}
