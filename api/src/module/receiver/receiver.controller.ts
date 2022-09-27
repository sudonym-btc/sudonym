import { Controller, Get, Inject, Param, Post, Query } from '@nestjs/common';
import { CurrencyCode, TAddressType } from '@sudonym/models';
import { Type } from 'class-transformer';
import { IsInt, IsNumber, IsOptional, IsString } from 'class-validator';
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
	amountCurrency: CurrencyCode = "BTC";
}
@Controller('receive')
export class ReceiverController {
	@Inject(ReceiverService) receiveService: ReceiverService;

	@Get('invoice')
	getInvoice(
		@Query() query: ReceiveQuery
	) {
		return this.receiveService.getInvoice(query);
	}
}
