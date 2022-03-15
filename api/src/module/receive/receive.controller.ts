import { Controller, Get, Inject, Post, Query } from '@nestjs/common';
import { ReceiveService } from './receive.service';

@Controller('receive')
export class ReceiveController {

  @Inject(ReceiveService) receiveService: ReceiveService;

  @Get('invoice')
  getInvoice(@Query('potId') potId, @Query('type') type, @Query('amount') amount) {
    return this.receiveService.getInvoice(potId, type, amount);
  }
}