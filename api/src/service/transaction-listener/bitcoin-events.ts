import { options } from "../../command-line-args";
import * as bitcoin from 'bitcoinjs-lib';
import * as zmq from 'zeromq';
import { Injectable } from "@nestjs/common";
import { Subject } from "rxjs";
import { getConfig } from "src/config/config";
var sock = zmq.socket('sub');

@Injectable()
export class BitcoinEvents {

    onTransaction = new Subject();

    onModuleInit() {

        console.log("Connecting to bitcoin message queue at " + getConfig().bitcoinMQ)

        sock.connect_timeout = 1;

        sock.connect(getConfig().bitcoinMQ);
        sock.subscribe('rawtx');
        sock.subscribe('rawblock');

        sock.on('message', (topic, message) => {

            if (topic.toString() === 'rawtx') {
                var rawTx = message.toString('hex');
                var tx = bitcoin.Transaction.fromHex(rawTx);
                var txid = tx.getId();
                tx.ins = tx.ins.map(function (inn) {
                    try {
                        (inn as any).address = bitcoin.address.fromOutputScript(inn.script, bitcoin.networks.bitcoin);
                    } catch (e) { }
                    return inn;
                });
                tx.outs = tx.outs.map(function (out) {
                    try {
                        (out as any).address = bitcoin.address.fromOutputScript(out.script, bitcoin.networks.bitcoin);
                    } catch (e) { }
                    return out;
                });

                // console.log('received transaction', txid, tx);
                this.onTransaction.next(tx);
            }
        });

        sock.on('error', console.error);
    }

}
