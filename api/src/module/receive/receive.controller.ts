import { Controller, Get, Inject, Param, Post, Query } from '@nestjs/common';
import { CurrencyCode, TAddressType } from '@sudonym/models';
import { Type } from 'class-transformer';
import { IsInt, IsNumber, IsString } from 'class-validator';
import { ReceiveService } from './receive.service';

export class ReceiveQuery {
	@IsInt()
	@Type(() => Number)
	potId: number;
	@IsNumber()
	@Type(() => Number)
	amount: number = 0;
	@IsString()
	type?: TAddressType;
	@IsString()
	amountCurrency: CurrencyCode = "BTC";
}
@Controller('receive')
export class ReceiveController {
	@Inject(ReceiveService) receiveService: ReceiveService;

	@Get('invoice')
	getInvoice(
		@Query() query: ReceiveQuery
	) {
		return this.receiveService.getInvoice(query);
	}
}
