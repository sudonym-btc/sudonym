import { Inject } from '@nestjs/common';
import { ReceiveService } from 'src/module/receive/receive.service';
import { TransactionService } from 'src/module/transaction/transaction.service';

export abstract class TransactionListener {
    @Inject() receiveService: ReceiveService;
    @Inject() transactionService: TransactionService;

    onModuleInit() {
        this.listenIncoming();
        this.listenOutgoing();
    }
    listenIncoming() { }
    listenOutgoing() { }
}