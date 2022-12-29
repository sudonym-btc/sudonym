import { Inject, Injectable } from '@nestjs/common';
import { BillSplitParticipantService } from 'module/bill-split-participant/bill-split-participant.service';
import { TransactionService } from 'module/transaction/transaction.service';
import { BaseService } from '../base.service';
import { BillSplit } from './bill-split.model';

@Injectable()
export class BillSplitService extends BaseService(BillSplit) {
	@Inject(BillSplitParticipantService)
	private readonly billSplitParticipantService: BillSplitParticipantService;

	@Inject(TransactionService)
	private readonly transactionService: TransactionService;

	onModuleInit() {
		this.afterCreate.hook(async ({ entity, params }) => {
			if (entity.transactionId) {
				await this.transactionService.update(entity.transactionId, {
					billSplitId: entity.id,
				});
			}
			params.BillSplitParticipants =
				entity.BillSplitParticipants =
				entity.dataValues.BillSplitParticipants =
					await Promise.all(
						params.BillSplitParticipants.map((a) =>
							this.billSplitParticipantService
								.createOrUpdate({
									...a,
									billSplitId: entity.id,
								})
								.then((e) => e.entity)
						)
					);
		});
	}
}
