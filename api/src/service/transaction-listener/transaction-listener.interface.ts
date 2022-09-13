import { Inject } from '@nestjs/common';
import { ReceiveService } from 'module/receive/receive.service';
import { TransactionService } from 'module/transaction/transaction.service';

export abstract class TransactionListener {
	@Inject() receiveService: ReceiveService;
	@Inject() transactionService: TransactionService;

	onModuleInit() {
		this.listenIncoming();
		this.listenOutgoing();
	}
	listenIncoming() {}
	listenOutgoing() {}
}
