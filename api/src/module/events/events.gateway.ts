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
import { v4 as uuid } from 'uuid';
import { EventsService } from './events.service';

@WebSocketGateway(getConfig().wsPort, {
	cors: true,
})
export class EventsGateway implements OnGatewayConnection, OnGatewayDisconnect {
	private readonly logger = new Logger(EventsGateway.name);

	pendingEvents: { initialSend: Date; client: any; event: any }[] = [];

	@WebSocketServer()
	server: any;

	@Inject() eventsService: EventsService;
	@Inject() authService: AuthService;

	users: { [key: string]: any[] } = {};

	onModuleInit() {
		this.eventsService.onEvent.listen((e) => {
			this.broadcastToClients(e.userIds, e.event);
		});

		setInterval(() => {
			this.pendingEvents = this.pendingEvents.filter((i) => {
				return (
					(new Date().valueOf() - i.initialSend.valueOf()) / 1000 < 20
				);
			});
			for (const pendingItem of this.pendingEvents) {
				this.logger.log(
					'Resending unacked message',
					pendingItem.event.name,
					pendingItem.event.id
				);
				pendingItem.client.send(JSON.stringify(pendingItem.event));
			}
		}, 2000);
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
				const clonedE = {
					...e,
					id: uuid(),
				};

				this.pendingEvents.push({
					initialSend: new Date(),
					client: sock,
					event: clonedE,
				});

				sock.send(JSON.stringify(clonedE));
			}
		}
	}

	async handleDisconnect(client: any) {
		// Disregard any unsent events
		this.pendingEvents = this.pendingEvents.filter(
			(i) => i.client != client
		);
		this.logger.verbose('Websocket client disconnected');
		for (const i of Object.keys(this.users)) {
			this.users[i] = this.users[i].filter((sock) => sock != client);
			this.logger.verbose(
				this.users[i].length + ' users left for id ' + i
			);
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
			let lastPing = new Date();
			this.users[user.uid] = this.users[user.uid] || [];
			this.users[user.uid].push(client);
			this.logger.verbose(
				'Websocket client connected',
				user.uid,
				this.users[user.uid].length
			);
			const ping = () => {
				if ((new Date().valueOf() - lastPing.valueOf()) / 1000 > 5) {
					clearInterval(interval);
					this.handleDisconnect(client);
					return;
				}
				// this.logger.verbose('ping ' + user.uid);
				client.send(JSON.stringify({ id: uuid(), ping: true }));
			};
			const interval = setInterval(ping, 3000);
			ping();
			// When the client ACKs a message, remove from pending messages
			client.on('message', (msg: Buffer) => {
				const event = JSON.parse(msg.toString());
				// this.logger.verbose(event);
				lastPing = new Date();
				if (event.event == 'ack') {
					this.pendingEvents = this.pendingEvents.filter(
						(i) => i.event.id != event.id
					);
				}
			});
			client.on('disconnect', () => {
				clearInterval(interval);
				this.handleDisconnect(client);
			});
		} else {
			this.logger.verbose('No id provided for bsocket');
			client.close();
		}
	}
}
