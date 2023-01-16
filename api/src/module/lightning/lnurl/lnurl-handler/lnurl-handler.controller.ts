import { Controller, Get, Inject, Param, Query } from '@nestjs/common';
import { LnurlStatusResponse, PaymentRequestCallback } from '@sudonym/models';
import { LnUrlHandlerService } from './lnurl-handler.service';

@Controller('lnurl')
export class LnUrlHandlerController {
	@Inject(LnUrlHandlerService) service: LnUrlHandlerService;

	@Get('handle/:id')
	async handle(
		@Param('id') id,
		@Query() query
	): Promise<PaymentRequestCallback | LnurlStatusResponse> {
		return this.service.handle(id, query);
	}

	@Get('serve/:id')
	async serve(@Param('id') id) {
		return this.service.serve(id);
	}
}
