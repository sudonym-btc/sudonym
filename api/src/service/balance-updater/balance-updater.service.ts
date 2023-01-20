import { HttpException, Inject, Injectable, Logger } from '@nestjs/common';
import { BalanceLowError } from '@sudonym/models';
import { CurrencyService } from 'module/currency/currency.service';
import { PotService } from 'module/pot/pot.service';
import { TransactionService } from 'module/transaction/transaction.service';

@Injectable()
export class BalanceUpdaterService {
	@Inject(CurrencyService) private currencyService: CurrencyService;
	@Inject(PotService) private potService: PotService;
	@Inject(TransactionService) private transactionService: TransactionService;
	private readonly logger = new Logger(this.constructor.name);

	onModuleInit() {
		this.potService.beforeUpdate.hook(async ({ params, entity }) => {
			if (params.currency) {
				params.spendableBalance = (
					await this.currencyService.convert(
						entity.currency,
						params.currency,
						entity.spendableBalance
					)
				).amount;

				params.balance = (
					await this.currencyService.convert(
						entity.currency,
						params.currency,
						entity.balance
					)
				).amount;

				return;
			}
		});
		this.transactionService.afterCreate.hook(async ({ entity }) => {
			const pot = await this.potService.findOne(entity.potId);
			let newBalance = pot.balance;
			let newSpendableBalance = pot.spendableBalance;
			const amountInPotCurrency = (
				await this.currencyService.convert(
					entity.currencyCode,
					pot.currency,
					entity.totalAmount || entity.amount
				)
			).amount;

			if (entity.outgoing) {
				newBalance -= amountInPotCurrency;
				newSpendableBalance -= amountInPotCurrency;

				if (newBalance < 0 || newSpendableBalance < 0) {
					throw new HttpException(new BalanceLowError().name, 400);
				}
			} else {
				newBalance += amountInPotCurrency;
				if (entity.status == true) {
					newSpendableBalance += amountInPotCurrency;
				}
			}

			this.logger.log(
				`Updating balance for pot ${pot.id} ${pot.name} from `,
				{
					balance: pot.balance,
					spendableBalance: pot.spendableBalance,
				},
				'to',
				{
					balance: newBalance,
					spendableBalance: newSpendableBalance,
				}
			);

			await this.potService.update(pot.id, {
				balance: newBalance,
				spendableBalance: newSpendableBalance,
			});
		});

		this.transactionService.afterUpdate.hook(async ({ entity }) => {
			if (entity.changed('status')) {
				const pot = await this.potService.findOne(entity.potId);

				let newBalance = pot.balance;
				let newSpendableBalance = pot.spendableBalance;
				this.logger.debug(
					`Transaction status changed to ${entity.status} so updating balances`
				);
				const amountInPotCurrency = (
					await this.currencyService.convert(
						entity.currencyCode,
						pot.currency,
						entity.amount
					)
				).amount;
				this.logger.debug(
					'Amount was ',
					amountInPotCurrency,
					pot.currency
				);
				// Increase spendable balance when outgoing fails
				if (entity.outgoing) {
					if (entity.status == false) {
						newSpendableBalance += amountInPotCurrency;
						newBalance += amountInPotCurrency;
					}
					// If payment is incoming update balances
				} else {
					if (entity.status == true) {
						newSpendableBalance += amountInPotCurrency;
					} else {
						newBalance -= amountInPotCurrency;
					}
				}

				this.logger.debug('Updating to ', {
					balance: newBalance,
					spendableBalance: newSpendableBalance,
				});

				await this.potService.update(pot.id, {
					balance: newBalance,
					spendableBalance: newSpendableBalance,
				});
			}
		});
	}
}
