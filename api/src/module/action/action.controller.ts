import { Body, Controller, Get, Inject, Post, Query, Response } from '@nestjs/common';
import { Action, ActionParseResponse, Payment, Withdraw } from '@sudonym/models';
import { ActionService } from './action.service';

@Controller('action')
export class ActionController {
	@Inject(ActionService) actionService: ActionService;

	@Get('parse')
	async parse(@Query('address') address, @Response() res) {
		try {
			return res.json(await this.actionService.parse(address));
		} catch(e) {
			if(e instanceof ActionParseResponse) {
				res.status(503);
				return res.json(e);
			}
		}
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
