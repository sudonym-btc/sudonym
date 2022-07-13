import { Body, Controller, Get, Inject, Post, Query } from '@nestjs/common';
import { Payment } from '@sudonym/models';
import { PayService } from './pay.service';

@Controller('pay')
export class PayController {

  @Inject(PayService) payService: PayService;

  @Get('parse')
  async parse(@Query('address') address) {
    return this.payService.parseInvoice(address);
  }

  @Post('info')
  async getInfo(@Body('payment') payment: Payment) {
    return this.payService.getInfo(payment);
  }

  @Post('')
  pay(@Body('payment') payment: Payment) {
    return this.payService.pay(payment);
  } 
}