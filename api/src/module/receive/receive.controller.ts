import { Controller, Get, Inject, Param, Post, Query } from '@nestjs/common';
import { ReceiveService } from './receive.service';

@Controller('receive')
export class ReceiveController {

  @Inject(ReceiveService) receiveService: ReceiveService;

  @Get('invoice')
  getInvoice(@Query('potId') potId, @Query('type') type, @Query('amount') amount, @Query('currency') currency) {
    return this.receiveService.getInvoice(potId, type, amount, currency);
  }

}