import { Controller } from '@nestjs/common';
import { PartialType } from '@nestjs/swagger';
import { Transaction } from '@sudonym/models';
import { IsBoolean, IsNumber, IsOptional, IsString } from 'class-validator';
import { BaseController } from '../base.controller';
import { TransactionService } from './transaction.service';

export class CreateTransaction extends PartialType(Transaction) {
	@IsNumber()
	potId: number;
	@IsNumber()
	@IsOptional()
	senderId: number;
	@IsNumber()
	@IsOptional()
	receiverId: number;
	@IsNumber()
	@IsOptional()
	contactAddressId: number;
	@IsNumber()
	amount: number;
	@IsBoolean()
	outgoing: boolean;
	@IsString()
	currencyCode: string;
	@IsString()
	type: string;
	@IsString()
	description: string;
	@IsString()
	originalAddress: string;
	@IsString()
	address: string;
}
@Controller('transaction')
export class TransactionController extends BaseController({
	service: TransactionService,
	model: Transaction,
	create: {
		auth: true,
		input: CreateTransaction,
	},
	update: false,
}) {}
