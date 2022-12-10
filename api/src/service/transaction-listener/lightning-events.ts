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
		this.logger.debug(
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

		ws.on('open', () => {
			this.logger.debug('Connected to lightning message queue');
		});

		ws.on('close', () => {
			this.logger.error('Disconnected from lightning message queue');
			setTimeout(() => {
				this.reconnect();
			}, 2000);
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

export type LightningEvent =
	| {
			event: 'invoice';
			data: Bolt11Received;
	  }
	| {
			event: 'sendpay';
			data: WaitSendPayResponse;
	  };

export type PayResponse = {
	payment_preimage?: string; // (secret): the proof of payment: SHA256 of this payment_hash (always 64 characters)
	payment_hash: string; // (hash): the hash of the payment_preimage which will prove payment (always 64 characters)
	created_at: number; //(number): the UNIX timestamp showing when this payment was initiated
	parts: number; // (u32): how many attempts this took
	amount_msat: number; // (msat): Amount the recipient received
	amount_sent_msat: number; // Total amount we sent (including fees)
	status: 'complete' | 'pending' | 'failed'; // status of payment (one of )
	destination?: string; // (pubkey, optional): the final destination of the payment
	warning_partial_completion;
};

export type SendPayResponse = {
	id: string;
	payment_hash: string; // (hash): the hash of the payment_preimage which will prove payment (always 64 characters)
	status: string; // (string): status of the payment (could be complete if already sent previously) (one of “pending”, “complete”)
	created_at: number; // (u64): the UNIX timestamp showing when this payment was initiated
	amount_sent_msat: number; // amount sent
	groupid?: number; // Grouping key to disambiguate multiple attempts to pay an invoice or the same payment_hash
	amount_msat?: number; // The amount delivered to destination (if known)
	destination?: string; // the final destination of the payment if known
	completed_at: number; // the UNIX timestamp showing when this payment was completed
	label?: string; // the label, if given to sendpay
	partid?: number; // the partid, if given to sendpay
	bolt11?: string; // (string, optional): the bolt11 string (if supplied)
	bolt12?: string; // (string, optional): the bolt12 string (if supplied: experimental-offers only).
};

export type WaitSendPayResponse = {
	id: number; // (u64): unique ID for this payment attempt
	payment_hash: string; // (hash): the hash of the payment_preimage which will prove payment (always 64 characters)
	status: string; // (string): status of the payment (always “complete”)
	created_at: number; // (u64): the UNIX timestamp showing when this payment was initiated
	amount_sent_msat: number; // (msat): The amount sent
	msatoshi_sent: number; // added synth (msat): The amount sent
	groupid?: number; // (u64, optional): Grouping key to disambiguate multiple attempts to pay an invoice or the same payment_hash
	amount_msat?: number; // (msat, optional): The amount delivered to destination (if known)
	destination?: string; // (pubkey, optional): the final destination of the payment if known
	completed_at?: number; // (number, optional): the UNIX timestamp showing when this payment was completed
	label?: string; // (string, optional): the label, if given to sendpay
	partid?: number; // (u64, optional): the partid, if given to sendpay
	bolt11?: string; // (string, optional): the bolt11 string (if pay supplied one)
	bolt12?: string; // (string, optional): the bolt12 string (if supplied for pay: experimental-offers only).

	erring_index?: string; //The index of the node along the route that reported the error. 0 for the local node, 1 for the first hop, and so on.
	erring_node?: string; // The hex string of the pubkey id of the node that reported the error.
	erring_channel?: string; //The short channel ID of the channel that has the error (or the final channel if the destination raised the error).
	erring_direction?: number; // The direction of traversing the erring_channel:
	failcode?: number; // The failure code, as per BOLT #4.
	failcodename?: string; // The human-readable name corresponding to failcode, if known.
	failreason?: string; // todo: discover which method throws this field
};
