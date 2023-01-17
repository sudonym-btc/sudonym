import { MSATOSHIS } from '@sudonym/models';
import { TransactionService } from 'module/transaction/transaction.service';
import { UserDevice } from 'module/user-device/user-device.model';
import { FirebaseNotificationService } from 'service/firebase-notification/firebase-notification.service';
import waitForExpect from 'wait-for-expect';
import { bolt11Encode } from './mock/classes';
import { scaffoldGroup } from './mock/scaffold-group';
import { scaffoldTest } from './mock/scaffold-test';

scaffoldGroup('Notifications', (scaffold) => {
	scaffoldTest(
		scaffold,
		'should send success notification',
		async (entities) => {
			await UserDevice.create({
				uid: entities.user[0].id,
				token: 'xyz',
			});
			const addr = bolt11Encode(1 * MSATOSHIS).paymentRequest;
			scaffold.app.get(TransactionService).create({
				outgoing: false,
				potId: entities.pot[0].id,
				type: 'bolt11',
				currencyCode: 'BTC',
				originalAddress: addr,
				address: addr,
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
		}
	);
});
