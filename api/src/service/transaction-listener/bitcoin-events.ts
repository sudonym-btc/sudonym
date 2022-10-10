import * as bitcoin from 'bitcoinjs-lib';
import * as zmq from 'zeromq';
import { Injectable } from '@nestjs/common';
import { Subject } from 'rxjs';
import { getConfig } from 'config/config';
const sock = zmq.socket('sub');
import { Logger } from '@nestjs/common';
import { RecursivePartial } from '@sudonym/models/src/recursive-partial';

type TxOutput = bitcoin.TxOutput & {
	txid: string;
	address: string;
	fromAddress: string;
};
export class BitcoinEvent extends bitcoin.Transaction {
	ins: (bitcoin.TxInput & { address: string })[];
	outs: TxOutput[];
}

const network =
	getConfig().network == 'regtest'
		? bitcoin.networks.regtest
		: getConfig().network == 'testnet'
		? bitcoin.networks.testnet
		: bitcoin.networks.bitcoin;

@Injectable()
export class BitcoinEvents {
	onTransaction = new Subject<RecursivePartial<BitcoinEvent>>();
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
				const tx = bitcoin.Transaction.fromHex(rawTx) as BitcoinEvent;
				const txid = tx.getId();
				tx.ins = tx.ins.map(function (inn) {
					try {
						inn.address = bitcoin.address.fromOutputScript(
							inn.script,
							network
						);
					} catch (e) {}
					return inn;
				});
				tx.outs = tx.outs.map(function (out) {
					try {
						out.fromAddress =
							tx.ins.length > 0
								? (tx.ins[0] as any).address
								: null;

						out.address = bitcoin.address.fromOutputScript(
							out.script,
							network
						);
						out.txid = txid;
					} catch (e) {}
					return out;
				});

				this.logger.verbose('Received onchain transaction', txid, tx);
				this.onTransaction.next(tx);
			}
		});

		sock.on('error', this.logger.error);
	}
}
