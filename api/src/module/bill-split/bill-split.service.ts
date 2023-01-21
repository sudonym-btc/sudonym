import { HttpException, Inject, Injectable } from '@nestjs/common';
import { BillSplitParticipant, calcAmountLeft } from '@sudonym/models';
import { BillSplitParticipantService } from 'module/bill-split-participant/bill-split-participant.service';
import { roundToDisplay } from 'module/transaction/transaction.model';
import { TransactionService } from 'module/transaction/transaction.service';
import { ValidationError, ValidationErrorItem } from 'sequelize';
import { BaseService } from '../base.service';
import { BillSplit } from './bill-split.model';

@Injectable()
export class BillSplitService extends BaseService(BillSplit) {
	@Inject(BillSplitParticipantService)
	private readonly billSplitParticipantService: BillSplitParticipantService;

	@Inject(TransactionService)
	private readonly transactionService: TransactionService;

	onModuleInit() {
		this.beforeCreate.hook((params) => {
			// Check that the participant amounts make up the complete amount
			const amountLeft = roundToDisplay(
				calcAmountLeft(params, [
					...Array(params.BillSplitParticipants.length).keys(),
				]),
				params.currency
			);
			if (Math.abs(amountLeft) > Math.pow(10, -8)) {
				// Must be closer than 1 sat
				throw new HttpException(
					'Bill split amounts off by ' + amountLeft.toString(),
					400
				);
			}

			if (!validateParticipants(params.BillSplitParticipants)) {
				throw new ValidationError('unique', [
					new ValidationErrorItem(
						'',
						'validation error',
						'amount',
						params.BillSplitParticipants.toString(),
						params,
						'',
						'',
						[]
					),
				]);
			}
			// Fulfill the first contribution if the user has already paid the bill
			if (params.transactionId) {
				params.BillSplitParticipants[0].amountPaid =
					params.BillSplitParticipants[0].amount;
				params.BillSplitParticipants[0].paid = true;
			}
		});
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

export const validateParticipants = (participtants: BillSplitParticipant[]) => {
	return (
		Array.isArray(participtants) &&
		participtants.slice(1).filter((p) => p.amount <= 0).length == 0
	);
};
