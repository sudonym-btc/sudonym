import { Inject, Injectable, Logger } from '@nestjs/common';
import { getConfig } from 'config/config';
import * as fs from 'fs';
import * as WebSocket from 'ws';
import { Subject } from 'rxjs';
import { LightningNodeService } from '../lightning-node/lightning-node.service';
import { Bolt11Received } from '@sudonym/models';

@Injectable()
export class LightningEvents {
	private readonly logger = new Logger(LightningEvents.name);

	@Inject() LightningNodeService: LightningNodeService;
	private macaroon;
	private url = getConfig().lightningREST.replace('http', 'ws');
	public onEvent = new Subject<LightningEvent>();

	reconnect() {
		this.logger.verbose(
			'Connecting to lightning message queue at ' + this.url
		);
		const ws = new WebSocket(this.url + '/v1/ws', ['json'], {
			rejectUnauthorized: false,
			headers: {
				'sec-websocket-protocol': this.macaroon,
			},
		});
		ws.on('message', (data) => {
			data = JSON.parse(data);
			if (data.type == 'Buffer') {
				data.data = Buffer.from(data.data);
			}
			this.logger.verbose('Lightning event received: ', data);
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
		this.macaroon = Buffer.from(
			fs.readFileSync(getConfig().macaroonFile)
		).toString('base64');
		// const ws = new WebSocket(this.url + "/v1/ws", [this.macaroon, 'json'], {
		this.reconnect();

		this.onEvent.subscribe((e) => {
			this.logger.verbose('EVENT', e);
		});
	}
}

export class LightningEvent {
	event: 'invoice' | 'channel';
	data: Bolt11Received;
}
