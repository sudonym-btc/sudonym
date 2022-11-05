import { Inject, Injectable, Logger } from '@nestjs/common';
import { Bolt11Received } from '@sudonym/models';
import { Config, getConfig } from 'config/config';
import * as fs from 'fs';
import { Subject } from 'rxjs';
import * as WebSocket from 'ws';
import { LightningNodeService } from '../lightning-node/lightning-node.service';

@Injectable()
export class LightningEvents {
	@Inject(Config) private readonly config: Config;

	private readonly logger = new Logger(LightningEvents.name);

	@Inject() LightningNodeService: LightningNodeService;
	public onEvent = new Subject<LightningEvent>();

	getUrl() {
		return this.config.lightningREST.replace('http', 'ws');
	}

	reconnect() {
		this.logger.verbose(
			'Connecting to lightning message queue at ' + this.getUrl()
		);
		const ws = new WebSocket(this.getUrl() + '/v1/ws', ['json'], {
			rejectUnauthorized: false,
			headers: {
				'sec-websocket-protocol': Buffer.from(
					fs.readFileSync(getConfig().macaroonFile)
				).toString('base64'),
			},
		});
		ws.on('message', (data) => {
			data = JSON.parse(data);
			if (data.type == 'Buffer') {
				data.data = Buffer.from(data.data);
			}
			this.onEvent.next(data);
		});

		ws.on('error', (data) => {
			this.logger.error('error: %s', data);
			this.reconnect();
		});

		ws.on('open', () => {
			this.logger.verbose('Connected to lightning message queue');
		});

		ws.on('close', () => {
			this.logger.error('Disconnected from lightning message queue');
			this.reconnect();
		});
	}

	onModuleInit() {
		// const ws = new WebSocket(this.url + "/v1/ws", [this.macaroon, 'json'], {
		this.reconnect();

		this.onEvent.subscribe((e) => {
			this.logger.verbose('EVENT', e);
		});
	}
}

export class LightningEvent {
	event: 'invoice' | 'channel' | 'sendpay';
	data: Bolt11Received;
}
