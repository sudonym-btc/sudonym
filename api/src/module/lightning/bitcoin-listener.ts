import { options } from "../../command-line-args";
import * as bitcoin from 'bitcoinjs-lib';
import * as zmq from 'zeromq';
import { Injectable } from "@nestjs/common";
var sock = zmq.socket('sub');
var addr = options.zeromq || 'tcp://192.168.64.6:30315'; //|| 'tcp://localhost:32207' 

@Injectable()
export class BitcoinListener {

    start() {

        sock.connect_timeout = 1;

        sock.connect(addr);
        sock.subscribe('rawtx');
        sock.subscribe('rawblock');

        sock.on('message', function (topic, message) {

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

                console.log('received transaction', txid, tx);
            }
        });

        sock.on('error', console.error);
    }

}
