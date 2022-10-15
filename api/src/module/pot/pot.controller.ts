import { Body, Controller, Post } from '@nestjs/common';
import { CurrencyCode } from '@sudonym/models';
import { Type } from 'class-transformer';
import { IsOptional, IsString } from 'class-validator';
import { RequestType } from 'helper/parse-request.decorator';
import { RecursivePartial } from 'sequelize-typescript/dist/shared/types';
import { BaseController } from '../base.controller';
import { Pot } from './pot.model';
import { PotService } from './pot.service';

export class CreatePot {
	@IsString()
	name: number;

	@IsString()
	currency: String;
}
@Controller('pot')
export class PotController extends BaseController(PotService, Pot) {
	@Post('')
	creater(@Body() params: CreatePot): Promise<Pot> {
		return super.create(params as any);
	}
}
