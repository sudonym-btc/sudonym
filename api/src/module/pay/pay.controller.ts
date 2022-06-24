import { Body, Controller, Get, Inject, Post, Query } from '@nestjs/common';
import { PayService } from './pay.service';

@Controller('pay')
export class PayController {

  @Inject(PayService) payService: PayService;

  @Get('info')
  async getInfo(@Query('address') address, @Query('amount') amount) {
    return this.payService.getInfo(address, amount);
  }

  @Post('')
  pay(@Body('address') address, @Body('amount') amount, @Body() data) {
    console.log(data);
    return this.payService.pay(address, amount);
  } 
}