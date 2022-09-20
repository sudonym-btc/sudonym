import { Inject, Injectable } from '@nestjs/common';
import { PotService } from 'module/pot/pot.service';
import { Transaction } from 'module/transaction/transaction.model';
import { TransactionService } from 'module/transaction/transaction.service';
import * as admin from 'firebase-admin';
import { CurrencyService } from 'module/currency/currency.service';

@Injectable()
export class BalanceUpdaterService {
	@Inject(CurrencyService) currencyService: CurrencyService;
	@Inject(PotService) potService: PotService;
	@Inject(TransactionService) transactionService: TransactionService;

	onModuleInit() {
		this.transactionService.onAfterCreated.hook(async (t) => {
			const pot = await this.potService.findOne(t.potId);
			let newBalance = pot.balance;
			let newSpendableBalance = pot.spendableBalance;
			const amountInPotCurrency = (
				await this.currencyService.convert(
					t.currencyCode,
					pot.currency,
					t.amount
				)
			).amount;

			if (t.outgoing) {
				newBalance -= amountInPotCurrency;
				newSpendableBalance -= amountInPotCurrency;
			} else {
				newBalance += amountInPotCurrency;
				if (t.status == true) {
					newSpendableBalance += amountInPotCurrency;
				}
			}

			await this.potService.update(pot.id, {
				balance: newBalance,
				spendableBalance: newSpendableBalance,
			});
			this.triggerNotification(t);
		});

		this.transactionService.onAfterUpdated.hook(async (t) => {
			const pot = await this.potService.findOne(t.potId);

			let newBalance = pot.balance;
			let newSpendableBalance = pot.spendableBalance;

			const amountInPotCurrency = (
				await this.currencyService.convert(
					t.currencyCode,
					pot.currency,
					t.amount
				)
			).amount;

			if (t.changed('status')) {
				// Increase spendable balance when outgoing fails
				if (t.outgoing) {
					if (t.status == false)
						newSpendableBalance += amountInPotCurrency;
				} else {
					if (t.status == true) {
						newSpendableBalance += amountInPotCurrency;
					} else {
						newBalance -= amountInPotCurrency;
					}
				}

				await this.potService.update(pot.id, {
					balance: newBalance,
					spendableBalance: newSpendableBalance,
				});

				this.triggerNotification(t);
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
		admin
			.messaging()
			.send(message)
			.then((response) => {
				// Response is a message ID string.
				console.log('Successfully sent message:', response);
			})
			.catch((error) => {
				console.log('Error sending message:', error);
			});
	}
}
