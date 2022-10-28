import { Inject, Injectable, Logger } from '@nestjs/common';
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
import { merge } from 'rxjs';
import { Message } from 'firebase-admin/lib/messaging/messaging-api';

@Injectable()
export class FirebaseNotificationService {
	@Inject(CurrencyService) private currencyService: CurrencyService;
	@Inject(PotService) private potService: PotService;
	@Inject(TransactionService) private transactionService: TransactionService;
	@Inject(UserDeviceService) private userDeviceService: UserDeviceService;
	@Inject(FIREBASE_ADMIN) private firebaseAdmin: T_FIREBASE_ADMIN;
	private readonly logger = new Logger(this.constructor.name);

	onModuleInit() {
		merge(this.transactionService.onAfterCreated, this.transactionService.onAfterUpdated).subscribe(this.triggerNotification.bind(this));
	}

	async triggerNotification(entity: Transaction) {

		if (!entity.isNewRecord && !entity.changed('status')) return;

		const users = await this.transactionService.getUserIds(entity.id);
		const pot = await this.potService.findOne(entity.potId);

		let notification: Message & any = {
			data: { data: JSON.stringify(entity.toJSON()) },
			body: "Click to check transaction",
		};


		const formattedAmount = this.currencyService.format((await this.currencyService.convert(entity.currencyCode, pot.currency, entity.amount)).amount, pot.currency);

		if (entity.outgoing) {
			// Outgoing transactions
			if (entity.status) {
				notification.title = formattedAmount + ' were spent from your account';
			} else if (entity.status == false) {
				notification.title = 'Failed to send ' + formattedAmount + ' from your account';
			} else {
				return;
			}
		} else {
			// Incoming transactions
			if (entity.status) {
				notification.title = formattedAmount + ' were sent to your account';
			} else {
				return;
			}

		}

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
				notification,
				token: device.token,
			};
			this.sendNotification(message);
		}
	}

	sendNotification(message) {
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
