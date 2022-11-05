import { Body, Controller, Post } from '@nestjs/common';
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
@Controller('pot')
export class PotController extends BaseController({
	service: PotService,
	model: Pot,
}) {
	@Post('')
	creater(@Body() params: CreatePot): Promise<Pot> {
		return super.create(params as any);
	}
}
