import { Inject, Injectable, Logger } from '@nestjs/common';
import { BillSplitParticipantService } from 'module/bill-split-participant/bill-split-participant.service';
import { BillSplitService } from 'module/bill-split/bill-split.service';
import { CurrencyService } from 'module/currency/currency.service';
import { TransactionService } from 'module/transaction/transaction.service';

@Injectable()
export class TransactionBillSplitLinkerService {
	private readonly logger = new Logger(this.constructor.name);

	@Inject() transactionService: TransactionService;
	@Inject() billSplitParticipantService: BillSplitParticipantService;
	@Inject() billSplitService: BillSplitService;
	@Inject() currencyService: CurrencyService;

	onModuleInit() {
		this.transactionService.afterCreate.hook(async ({ entity }) => {
			if (entity.status == true && entity.outgoing == false) {
				if (entity.Receiver.billSplitParticipantId) {
					const p = await this.billSplitParticipantService.findOne(
						entity.Receiver.billSplitParticipantId
					);
					const billSplit = await this.billSplitService.findOne(
						p.billSplitId
					);
					const amountPaid = (p.amountPaid += (
						await this.currencyService.convert(
							entity.currencyCode,
							billSplit.currency,
							entity.amount
						)
					).amount);

					await this.billSplitParticipantService.update(
						entity.Receiver.billSplitParticipantId,
						{
							amountPaid,
							paid: amountPaid >= p.amount,
						}
					);
				}
			}
		});
	}
}
