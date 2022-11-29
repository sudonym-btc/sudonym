import { Inject, Logger } from '@nestjs/common';
import {
	OnGatewayConnection,
	OnGatewayDisconnect,
	WebSocketGateway,
	WebSocketServer,
} from '@nestjs/websockets';
import { Event } from '@sudonym/models';
import { getConfig } from 'config/config';
import { AuthService } from 'module/auth/auth.service';
import { EventsService } from './events.service';

@WebSocketGateway(getConfig().wsPort, {
	cors: true,
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
		for (const uid of uids) {
			this.logger.log(
				'Sockets for user',
				uid,
				(this.users[uid] || []).length
			);
			for (const sock of this.users[uid] || []) {
				sock.send(JSON.stringify(e));
			}
		}
	}

	async handleDisconnect(client: any) {
		for (const i of Object.keys(this.users)) {
			for (const key in this.users[i]) {
				if (this.users[i][key] == client) {
					delete this.users[i][key];
					this.logger.verbose(
						'Websocket client disconnected',
						i,
						this.users[i].length
					);
				}
			}
		}
	}

	async handleConnection(client, ...args: any[]) {
		const headers = args[0].headers;
		const token =
			new URL('https://example.com' + args[0].url).searchParams.get(
				'x-access-token'
			) || headers['x-access-token'];
		const user = await this.authService.auth({
			token,
		});

		if (user && user.uid) {
			this.users[user.uid] = this.users[user.uid] || [];
			this.users[user.uid].push(client);
			this.logger.verbose(
				'Websocket client connected',
				user.uid,
				this.users[user.uid].length
			);
			client.send('connected');
		} else {
			this.logger.verbose('No id provided for bsocket');
			client.close();
		}
	}
}
