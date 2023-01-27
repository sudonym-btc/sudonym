import { Inject, Injectable } from '@nestjs/common';
import { PotService } from 'module/pot/pot.service';
import { TransactionTagService } from 'module/transaction-tag/transaction-tag.service';
import { BaseService } from '../base.service';
import { Transaction } from './transaction.model';

@Injectable()
export class TransactionService extends BaseService(Transaction) {
	@Inject() potService: PotService;
	@Inject() transactionTagService: TransactionTagService;

	async onModuleInit() {
		this.beforeCreate.hook(async (params) => {
			params.potId =
				params.potId || (await this.potService.findForUser()).id;
		});

		this.afterCreate.hook(async ({ entity, params }) => {
			params.Tags =
				entity.Tags =
				entity.dataValues.Tags =
					await Promise.all(
						(params.Tags || []).map((a) =>
							this.transactionTagService
								.createOrUpdate({
									...a,
									transactionId: entity.id,
								})
								.then((e) => e.entity)
						)
					);
		});
	}
}
