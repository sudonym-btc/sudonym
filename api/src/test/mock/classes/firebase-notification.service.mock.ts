import { FirebaseNotificationService } from "service/firebase-notification/firebase-notification.service";

export class MockFirebaseNotificationService extends FirebaseNotificationService {
	sendNotification = jest.fn(async (invoice) => {});
}