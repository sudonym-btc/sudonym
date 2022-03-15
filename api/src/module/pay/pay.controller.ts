import { Controller, Get, Inject, Post, Query } from '@nestjs/common';
import { PayService } from './pay.service';

@Controller('user/pay')
export class PayController {

  @Inject(PayService) payService: PayService;

  @Get('info')
  getInfo(@Query('address') address, @Query('amount') amount) {
    return this.payService.getInfo(address, amount);
  }

  @Post('')
  pay(@Query('address') address, @Query('amount') amount) {
    return this.payService.pay(address, amount);
  } 
}