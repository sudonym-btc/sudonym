import { Controller, Get, Inject, Param, Query } from '@nestjs/common';
import { LnUrlHandlerService } from './lnurl-handler.service';

@Controller('lnurl')
export class LnUrlHandlerController {
	@Inject(LnUrlHandlerService) service: LnUrlHandlerService;

	@Get('handle/:id')
	async handle(@Param('id') id, @Query() query) {
		return this.service.handle(id, query);
	}

	@Get('serve/:id')
	async overwriteFindOne(@Param('id') id) {
		return this.service.serve(id);
	}
}
