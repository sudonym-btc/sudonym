import { Injectable } from '@nestjs/common';
import { Callback } from '../../helper/callback';

export class TriggeredEvent {
	constructor(public event, public userIds) {}
}
@Injectable()
export class EventsService {
	onEvent = new Callback<TriggeredEvent>();
	trigger(e: TriggeredEvent) {
		console.log('Triggering', e.event.name);
		this.onEvent.execute(e);
	}
}
