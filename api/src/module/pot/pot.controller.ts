import { Controller } from '@nestjs/common';
import { BaseController } from '../base.controller';
import { Pot } from './pot.model';
import { PotService } from './pot.service';

@Controller('pot')
export class PotController extends BaseController(PotService, Pot) {}
