import { Body, Controller, Get, Inject, Post, Query } from '@nestjs/common';
import { Action } from '@sudonym/models';
import { ActionService } from './action.service';

@Controller('action')
export class ActionController {
	@Inject(ActionService) actionService: ActionService;

	@Get('parse')
	async parse(@Query('address') address) {
		return this.actionService.parse(address);
	}

	@Post('info')
	async getInfo(@Body('action') action: Action) {
		console.log(action);
		return this.actionService.getInfo(Action.from(action));
	}

	@Post('')
	execute(@Body('action') action: Action) {
		return this.actionService.execute(Action.from(action));
	}
}
