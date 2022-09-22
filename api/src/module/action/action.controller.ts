import { Body, Controller, Get, Inject, Post, Query } from '@nestjs/common';
import { Action, Payment, Withdraw } from '@sudonym/models';
import { ActionService } from './action.service';

@Controller('action')
export class ActionController {
	@Inject(ActionService) actionService: ActionService;

	@Get('parse')
	async parse(@Query('address') address) {
		return this.actionService.parse(address);
	}

	@Post('info')
	async getPaymentInfo(@Body('action') action: any) {
		return this.actionService.getInfo(Action.from(action));
	}

	@Post('')
	execute(@Body('action') action: any) {
		return this.actionService.execute(Action.from(action));
	}
}
