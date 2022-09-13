import * as bitcoin from 'bitcoinjs-lib';
import * as zmq from 'zeromq';
import { Injectable } from '@nestjs/common';
import { Subject } from 'rxjs';
import { getConfig } from 'config/config';
const sock = zmq.socket('sub');
import { Logger } from '@nestjs/common';

@Injectable()
export class BitcoinEvents {
	onTransaction = new Subject();
	private readonly logger = new Logger(BitcoinEvents.name);

	onModuleInit() {
		this.logger.verbose(
			'Connecting to bitcoin message queue at ' + getConfig().bitcoinMQ
		);

		sock.connect_timeout = 1;

		sock.connect(getConfig().bitcoinMQ);
		sock.subscribe('rawtx');
		sock.subscribe('rawblock');

		sock.on('message', (topic, message) => {
			if (topic.toString() === 'rawtx') {
				const rawTx = message.toString('hex');
				const tx = bitcoin.Transaction.fromHex(rawTx);
				const txid = tx.getId();
				tx.ins = tx.ins.map(function (inn) {
					try {
						(inn as any).address = bitcoin.address.fromOutputScript(
							inn.script,
							bitcoin.networks.bitcoin
						);
					} catch (e) {}
					return inn;
				});
				tx.outs = tx.outs.map(function (out) {
					try {
						(out as any).address = bitcoin.address.fromOutputScript(
							out.script,
							bitcoin.networks.bitcoin
						);
					} catch (e) {}
					return out;
				});

				this.logger.debug('Received onchain transaction', txid, tx);
				this.onTransaction.next(tx);
			}
		});

		sock.on('error', this.logger.error);
	}
}
