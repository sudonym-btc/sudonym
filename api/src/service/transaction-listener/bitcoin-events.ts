import * as bitcoin from 'bitcoinjs-lib';
import * as zmq from 'zeromq';
import { Injectable } from '@nestjs/common';
import { Subject } from 'rxjs';
import { getConfig } from 'config/config';
const sock = zmq.socket('sub');
import { Logger } from '@nestjs/common';

type TxOutput = bitcoin.TxOutput & {
	address: string;
}
export class BitcoinEvent extends bitcoin.Transaction {
	outs: TxOutput[];
}

const network = getConfig().network == "regtest" ? bitcoin.networks.regtest : (getConfig().network == "testnet" ? bitcoin.networks.testnet : bitcoin.networks.bitcoin);

@Injectable()
export class BitcoinEvents {
	onTransaction = new Subject<BitcoinEvent>();
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
							network
						);
					} catch (e) { }
					return inn;
				});
				tx.outs = tx.outs.map(function (out) {
					try {
						(out as any).address = bitcoin.address.fromOutputScript(
							out.script,
							network
						);
					} catch (e) { }
					return out;
				});

				this.logger.debug('Received onchain transaction', txid, tx);
				this.onTransaction.next(tx as any);
			}
		});

		sock.on('error', this.logger.error);
	}
}
