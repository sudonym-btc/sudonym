import { Injectable, Logger } from '@nestjs/common';
import { Callback } from '../../helper/callback';

export class TriggeredEvent {
	constructor(public event, public userIds) {}
}
@Injectable()
export class EventsService {
	onEvent = new Callback<TriggeredEvent>();
	private readonly logger = new Logger(this.constructor.name);
	trigger(e: TriggeredEvent) {
		this.logger.debug('Triggering', e.event.name, e.userIds);
		this.onEvent.execute(e);
	}
}
