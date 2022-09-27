import { Inject, Logger } from '@nestjs/common';
import {
	OnGatewayConnection,
	WebSocketGateway,
	WebSocketServer,
} from '@nestjs/websockets';
import { Event } from '@sudonym/models';
import { getConfig } from 'config/config';
import { EventsService } from './events.service';

@WebSocketGateway(getConfig().wsPort, {
	cors: {
		origin: '*',
	},
})
export class EventsGateway implements OnGatewayConnection {
	private readonly logger = new Logger(EventsGateway.name);

	@WebSocketServer()
	server: any;

	@Inject() eventsService: EventsService;

	onModuleInit() {
		this.eventsService.onEvent.listen((e: Event) => {
			this.broadcastToClients([], e);
		});
	}

	broadcastToClients(uids, e: Event) {
		this.logger.log(
			'Emitting ' +
				e.name +
				' to ' +
				(this.server.clients || new Set()).size +
				' clients'
		);
		(this.server.clients || new Set()).forEach((client) => {
			client.send(JSON.stringify(e));
		});
	}

	handleConnection(client, ...args: any[]) {
		this.logger.verbose('Websocket client connected');
		setInterval(() => {
			// client.send(JSON.stringify(new Event('transaction.created', mocks.transaction.mocks[0])));
		}, 5000);
	}
}
