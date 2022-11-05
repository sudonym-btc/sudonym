import { TransactionService } from 'module/transaction/transaction.service';
import { UserDevice } from 'module/user-device/user-device.model';
import { FirebaseNotificationService } from 'service/firebase-notification/firebase-notification.service';
import waitForExpect from 'wait-for-expect';
import { scaffoldGroup } from './mock/scaffold-group';

scaffoldGroup('Notifications', (scaffold) => {
	it('should send success notification', async () => {
		await UserDevice.create({
			uid: scaffold.entities.user[0].id,
			token: 'xyz',
		});
		scaffold.app.get(TransactionService).create({
			outgoing: false,
			potId: scaffold.entities.pot[0].id,
			type: 'bolt11',
			currencyCode: 'BTC',
			originalAddress: 'lnbc1asdfghj',
			address: 'lnbc1asdfghj',
			status: true,
			amount: 1,
		});
		await waitForExpect(() => {
			expect(
				(
					scaffold.app.get(FirebaseNotificationService)
						.sendNotification as any
				).mock.calls.length
			).toBe(1);
		});
	});
});
