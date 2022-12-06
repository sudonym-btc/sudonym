import { Controller } from '@nestjs/common';
import { PartialType } from '@nestjs/swagger';
import { IsString } from 'class-validator';
import { BaseController } from '../base.controller';
import { Pot } from './pot.model';
import { PotService } from './pot.service';

export class CreatePot {
	@IsString()
	name: number;

	@IsString()
	currency: string;
}

export class UpdatePot extends PartialType(CreatePot) {}
@Controller('pot')
export class PotController extends BaseController({
	service: PotService,
	model: Pot,
	create: {
		input: CreatePot,
		validator: {
			whitelist: true,
		},
	},
	update: {
		input: UpdatePot,
		validator: {
			whitelist: true,
		},
	},
}) {}
// todo: look into GBP USD conversion error where £3 equallyed 5 dollars and then £4.10 equalled 5 dollars
