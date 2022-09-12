import { Inject, Injectable } from '@nestjs/common';
import { TransactionService } from 'src/module/transaction/transaction.service';
import { TransactionListener } from './transaction-listener.interface';
import { BitcoinEvents } from './bitcoin-events';
import { LightningNodeService } from '../lightning-node/lightning-node.service';

@Injectable()
export class BitcoinListener extends TransactionListener {

    @Inject() LightningNodeService: LightningNodeService;
    @Inject() bitcoinEvents: BitcoinEvents;
    @Inject() transactionService: TransactionService;

    listenIncoming() {
        this.bitcoinEvents.onTransaction.subscribe(e => {
            // console.log(e);
        });
    }

    listenOutgoing() {

    }

}
