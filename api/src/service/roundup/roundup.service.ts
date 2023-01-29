import { Inject, Injectable, Logger } from '@nestjs/common';
import { TRANSACTION_TAGS } from '@sudonym/models';
import { CurrencyService } from 'module/currency/currency.service';
import { PotUser } from 'module/pot-user/pot-user.model';
import { Pot } from 'module/pot/pot.model';
import { PotService } from 'module/pot/pot.service';
import { TransactionService } from 'module/transaction/transaction.service';
import { filter } from 'rxjs';

@Injectable()
export class RoundupService {
	@Inject(CurrencyService) private currencyService: CurrencyService;
	@Inject(PotService) private potService: PotService;
	@Inject(TransactionService) private transactionService: TransactionService;
	private readonly logger = new Logger(this.constructor.name);

	onModuleInit() {
		this.transactionService.onAfterCreated
			.pipe(
				// Only check outgoing payments
				filter((t) => t.outgoing),
				// Only check payments which aren't roundup payments themselves
				filter(
					(t) =>
						!t.Tags.map((tag) => tag.tagId).includes(
							parseInt(
								Object.keys(TRANSACTION_TAGS).find(
									(key) => TRANSACTION_TAGS[key] == 'roundup'
								)
							)
						)
				)
			)
			.subscribe(async (transaction) => {
				try {
					const potUser = await PotUser.findOne({
						where: {
							potId: transaction.potId,
						},
					});

					// Fetch roundup pots
					const pots = await Pot.findAll({
						where: {
							roundup: true,
						},
						include: [
							{
								required: true,
								model: PotUser,
								as: 'PotUser',
								where: {
									userId: potUser.userId,
								},
							},
						],
					});

					const usd = await this.currencyService.convert(
						transaction.currencyCode,
						'USD',
						transaction.amount,
						transaction.createdAt
					);
					const leftOver = Math.ceil(usd.amount) - usd.amount;
					if (leftOver <= 0) return;
					// test
					for (const pot of pots) {
						const roundupOutgoing =
							await this.transactionService.create({
								outgoing: true,
								amount: leftOver,
								currencyCode: 'USD',
								type: 'internal',
								status: true,
								potId: transaction.potId,
								transactionId: transaction.id,
								Tags: [
									{
										tagId: parseInt(
											Object.keys(TRANSACTION_TAGS).find(
												(key) =>
													TRANSACTION_TAGS[key] ==
													'roundup'
											)
										),
									},
								],
							});
						await this.transactionService.create({
							outgoing: false,
							amount: leftOver,
							currencyCode: 'USD',
							type: 'internal',
							status: true,
							potId: pot.id,
							transactionId: transaction.id,
							Tags: [
								{
									tagId: parseInt(
										Object.keys(TRANSACTION_TAGS).find(
											(key) =>
												TRANSACTION_TAGS[key] ==
												'roundup'
										)
									),
								},
							],
						});
					}
				} catch (e) {
					this.logger.error(e);
				}
			});
	}
}
