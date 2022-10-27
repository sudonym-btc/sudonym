import { Controller, Get, Inject, Param, Post, Query, UsePipes, ValidationPipe } from '@nestjs/common';
import { CurrencyCode, TAddressType } from '@sudonym/models';
import { Type } from 'class-transformer';
import { IsInt, IsNumber, IsOptional, IsString } from 'class-validator';
import { BaseController } from 'module/base.controller';
import { Receiver } from './receiver.model';
import { ReceiverService } from './receiver.service';

export class ReceiveQuery {
	@IsInt()
	@IsOptional()
	@Type(() => Number)
	parentId: number;
	@IsInt()
	@Type(() => Number)
	potId: number;
	@IsNumber()
	@Type(() => Number)
	amount: number = 0;
	@IsString()
	type?: TAddressType;
	@IsString()
	amountCurrency: CurrencyCode = 'BTC';
}
@Controller('receiver')
export class ReceiverController extends BaseController(
	ReceiverService,
	Receiver
) {
	@Inject(ReceiverService) receiveService: ReceiverService;

	@Get('invoice')
	getInvoice(@Query() query: ReceiveQuery) {
		return this.receiveService.create(query);
	}
}
