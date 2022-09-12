import { Controller, Get, Inject, Param, Query } from '@nestjs/common';
import { LnUrlHandlerService } from './lnurl-handler.service';


@Controller('lnurl')
export class LnUrlHandlerController {
    @Inject(LnUrlHandlerService) service: LnUrlHandlerService;

    @Get('handle/:id')
    async handle(@Param('id') id, @Query('amount') amount) {
    	return this.service.handle(id, amount);
    }

}