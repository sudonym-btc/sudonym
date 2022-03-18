import { Controller, Get, Inject, Param, Post, Query } from '@nestjs/common';
import { ReceiveService } from './receive.service';

@Controller('receive')
export class ReceiveController {

  @Inject(ReceiveService) receiveService: ReceiveService;

  @Get('invoice')
  getInvoice(@Query('potId') potId, @Query('type') type, @Query('amount') amount) {
    return this.receiveService.getInvoice(potId, type, amount);
  }

  @Get('lnurlp/:potId')
  async getPayInvoice(@Param('potId') potId: number, @Query('amount') amount: number) {
      return {
          pr: await this.receiveService.getInvoice(potId, 'bolt11', amount), // bech32-serialized lightning invoice
          routes: [], // an empty array
      }
  }
}