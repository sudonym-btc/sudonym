import { Controller } from '@nestjs/common';
import { BaseController } from '../base.controller';
import { PotUser } from './pot-user.model';
import { PotUserService } from './pot-user.service';

@Controller('potUser')
export class PotUserController extends BaseController({
	service: PotUserService,
	model: PotUser,
}) {}
