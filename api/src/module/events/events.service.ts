import { Injectable } from '@nestjs/common';
import { Event } from '@sudonym/models';
import { Callback } from '../../helper/callback';

@Injectable()
export class EventsService {
	onEvent = new Callback();
	trigger(e: Event) {
		this.onEvent.execute(e);
	}
}
