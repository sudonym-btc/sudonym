import { Injectable } from '@nestjs/common';
import { Event } from '@sudonym/models';
import { Callback } from '../../helper/callback';

@Injectable()
export class EventsService {
	onEvent = new Callback();
	trigger(e: Event) {
		console.log("Triggering ", e.name)
		this.onEvent.execute(e);
	}
}
