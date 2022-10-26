import { Inject, Injectable, Logger } from '@nestjs/common';
import { BalanceLowError } from 'helper/errors';
import { PotService } from 'module/pot/pot.service';
import { Transaction } from 'module/transaction/transaction.model';
import { TransactionService } from 'module/transaction/transaction.service';
import { CurrencyService } from 'module/currency/currency.service';
import {
	FIREBASE_ADMIN,
	T_FIREBASE_ADMIN,
} from 'service/firebase-admin/firebase-admin';
import { UserDeviceService } from 'module/user-device/user-device.service';
import { Op } from 'sequelize';

@Injectable()
export class BalanceUpdaterService {
	@Inject(CurrencyService) currencyService: CurrencyService;
	@Inject(PotService) potService: PotService;
	@Inject(TransactionService) transactionService: TransactionService;
	@Inject(UserDeviceService) userDeviceService: UserDeviceService;
	@Inject(FIREBASE_ADMIN) firebaseAdmin: T_FIREBASE_ADMIN;
	private readonly logger = new Logger(this.constructor.name);

	onModuleInit() {
		this.transactionService.afterCreate.hook(async ({ entity }) => {
			const pot = await this.potService.findOne(entity.potId);
			let newBalance = pot.balance;
			let newSpendableBalance = pot.spendableBalance;
			const amountInPotCurrency = (
				await this.currencyService.convert(
					entity.currencyCode,
					pot.currency,
					entity.amount
				)
			).amount;

			if (entity.outgoing) {
				newBalance -= amountInPotCurrency;
				newSpendableBalance -= amountInPotCurrency;

				if(newBalance < 0) {
					throw new BalanceLowError();
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
				`to`,
				{
					balance: newBalance,
					spendableBalance: newSpendableBalance,
				}
			);

			await this.potService.update(pot.id, {
				balance: newBalance,
				spendableBalance: newSpendableBalance,
			});
			this.triggerNotification(entity);
		});

		this.transactionService.afterUpdate.hook(async ({ entity }) => {
			const pot = await this.potService.findOne(entity.potId);

			let newBalance = pot.balance;
			let newSpendableBalance = pot.spendableBalance;

			const amountInPotCurrency = (
				await this.currencyService.convert(
					entity.currencyCode,
					pot.currency,
					entity.amount
				)
			).amount;

			if (entity.changed('status')) {
				// Increase spendable balance when outgoing fails
				if (entity.outgoing) {
					if (entity.status == false)
						newSpendableBalance += amountInPotCurrency;
				} else {
					if (entity.status == true) {
						newSpendableBalance += amountInPotCurrency;
					} else {
						newBalance -= amountInPotCurrency;
					}
				}

				await this.potService.update(pot.id, {
					balance: newBalance,
					spendableBalance: newSpendableBalance,
				});

				this.triggerNotification(entity);
			}
		});
	}

	async triggerNotification(t: Transaction) {
		const users = await this.transactionService.getUserIds(t.id);
		const pot = await this.potService.findOne(t.potId);
		this.logger.debug("Sending notification to", users);

		const userDevices = await this.userDeviceService.list({
			where: {
				uid: {
					[Op.in]: users
				}
			}
		});

		for (const device of userDevices.data) {

			const message = {
				data: { data: JSON.stringify(t.toJSON()) },
				notification: {
					title: this.currencyService.format((await this.currencyService.convert(t.currencyCode, pot.currency, t.amount)).amount, pot.currency) + ' was ' + (t.outgoing ? 'spent from' : 'sent to') + ' your account',
					body: "Click to check transaction",
				},
				token: device.token,
			};
			// Send a message to the device corresponding to the provided
			// registration token.
			this.firebaseAdmin
				.messaging()
				.send(message)
				.then((response) => {
					// Response is a message ID string.
					this.logger.debug('Successfully sent message:', response);
				})
				.catch((error) => {
					this.logger.debug('Error sending message:', error);
				});
		}
	}
}
