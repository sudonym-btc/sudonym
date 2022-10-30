import * as bitcoin from 'bitcoinjs-lib';
import * as zmq from 'zeromq';
import { Inject, Injectable } from '@nestjs/common';
import { Subject } from 'rxjs';
import { Config, getConfig } from 'config/config';
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

const network = (n) =>
	n == 'regtest'
		? bitcoin.networks.regtest
		: n == 'testnet'
		? bitcoin.networks.testnet
		: bitcoin.networks.bitcoin;

@Injectable()
export class BitcoinEvents {
	@Inject(Config) private readonly config: Config;

	onTransaction = new Subject<RecursivePartial<BitcoinEvent>>();
	private readonly logger = new Logger(BitcoinEvents.name);

	onModuleInit() {
		this.logger.verbose(
			'Connecting to bitcoin message queue at ' + this.config.bitcoinMQ
		);

		sock.connect_timeout = 1;

		sock.connect(this.config.bitcoinMQ);
		sock.subscribe('rawtx');
		sock.subscribe('rawblock');

		sock.on('message', (topic, message) => {
			if (topic.toString() === 'rawtx') {
				const rawTx = message.toString('hex');
				const tx = bitcoin.Transaction.fromHex(rawTx) as BitcoinEvent;
				const txid = tx.getId();
				tx.ins = tx.ins.map((inn) => {
					try {
						inn.address = bitcoin.address.fromOutputScript(
							inn.script,
							network(this.config.network)
						);
					} catch (e) {}
					return inn;
				});
				tx.outs = tx.outs.map((out) => {
					try {
						out.fromAddress =
							tx.ins.length > 0
								? (tx.ins[0] as any).address
								: null;

						out.address = bitcoin.address.fromOutputScript(
							out.script,
							network(this.config.network)
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
