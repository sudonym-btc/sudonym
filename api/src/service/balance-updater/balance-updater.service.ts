import { Inject, Injectable, Logger } from '@nestjs/common';
import { PotService } from 'module/pot/pot.service';
import { Transaction } from 'module/transaction/transaction.model';
import { TransactionService } from 'module/transaction/transaction.service';
import * as admin from 'firebase-admin';
import { CurrencyService } from 'module/currency/currency.service';
import {
	FIREBASE_ADMIN,
	T_FIREBASE_ADMIN,
} from 'service/firebase-admin/firebase-admin';

@Injectable()
export class BalanceUpdaterService {
	@Inject(CurrencyService) currencyService: CurrencyService;
	@Inject(PotService) potService: PotService;
	@Inject(TransactionService) transactionService: TransactionService;
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

	triggerNotification(t: Transaction) {
		// This registration token comes from the client FCM SDKs.
		const registrationToken =
			'cYPqDzBgTLuICZ0IR3Xi9f:APA91bFyAXt4l3HNBLMOb35e1Xr91DO8UI5Pd6oqDiE0HYcArACt1pvywuscwxqWqnlWyyTTZ_fZ_qL7AFSk4OqVD9m12ml2J1UPylvF-4BcosGJYwzsYK3bKux1ijci89Yedfe5NcfY';

		const message = {
			data: { data: JSON.stringify(t.toJSON()) },
			notification: {
				title: '$FooCorp up 1.43% on the day',
				body: '$FooCorp gained 11.80 points to close at 835.67, up 1.43% on the day.',
			},
			token: registrationToken,
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
