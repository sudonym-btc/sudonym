import { Inject } from "@nestjs/common";
import { ReceiveService } from "src/module/receive/receive.service";
import { TransactionSettlementService } from "src/module/transaction-settlement/transaction-settlement.service";
import { TransactionService } from "src/module/transaction/transaction.service";

export abstract class TransactionListener {
    @Inject() receiveService: ReceiveService;
    @Inject() transactionService: TransactionService;
    @Inject() transactionSettlementService: TransactionSettlementService;

    onModuleInit() {
        this.listenIncoming();
        this.listenOutgoing();
    }
    listenIncoming() {}
    listenOutgoing() {}
}