import { Inject } from '@nestjs/common';
import { ReceiverService } from 'module/receiver/receiver.service';
import { TransactionService } from 'module/transaction/transaction.service';

export abstract class TransactionListener {
	@Inject() receiveService: ReceiverService;
	@Inject() transactionService: TransactionService;

	onModuleInit() {
		this.listenIncoming();
		this.listenOutgoing();
	}
	listenIncoming() {}
	listenOutgoing() {}
}
