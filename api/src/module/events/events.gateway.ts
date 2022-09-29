import { Inject, Logger } from '@nestjs/common';
import {
	OnGatewayConnection,
	OnGatewayDisconnect,
	WebSocketGateway,
	WebSocketServer,
} from '@nestjs/websockets';
import { Event, User } from '@sudonym/models';
import { getConfig } from 'config/config';
import { AuthService } from 'module/auth/auth.service';
import { EventsService } from './events.service';

@WebSocketGateway(getConfig().wsPort, {
	cors: {
		origin: '*',
	},
})
export class EventsGateway implements OnGatewayConnection, OnGatewayDisconnect {
	private readonly logger = new Logger(EventsGateway.name);

	@WebSocketServer()
	server: any;

	@Inject() eventsService: EventsService;
	@Inject() authService: AuthService;

	users: { [key: string]: any[] } = {};

	onModuleInit() {
		this.eventsService.onEvent.listen((e) => {
			this.broadcastToClients(e.userIds, e.event);
		});
	}

	broadcastToClients(uids, e: Event) {
		this.logger.log('Emitting ' + e.name + ' to ' + uids.join(', '));
		console.log(uids, this.users);
		for (const uid of uids) {
			for (const sock of this.users[uid] || []) {
				sock.send(JSON.stringify(e));
			}
		}
	}

	async handleDisconnect(client: any) {
		for (let i of Object.keys(this.users)) {
			for (const key in this.users[i]) {
				if (this.users[i][key] == client) delete this.users[i][key];
			}
		}
	}

	async handleConnection(client, ...args: any[]) {
		const headers = args[0].headers;
		const user = await this.authService.auth({
			token: headers['x-access-token'],
		});
		if (user.uid) {
			this.logger.verbose('Websocket client connected');
			this.users[user.uid] = this.users[user.uid] || [];
			this.users[user.uid].push(client);
		} else {
			this.logger.verbose('No id provided for bsocket');
		}
	}
}
