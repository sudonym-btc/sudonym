import { Provider } from '@nestjs/common';
import { getConfig } from 'config/config';
import admin, { ServiceAccount } from 'firebase-admin';
import * as fs from 'fs';

export const FIREBASE_ADMIN = 'FB_ADMIN';

export type T_FIREBASE_ADMIN = typeof admin;

const fb = () => {
	return ['mock'].includes(getConfig().env)
		? {}
		: (() => {
			const serviceAccountPath =
				process.cwd() + '/src/config/service-account.json';
			const serviceAccount = fs.existsSync(serviceAccountPath)
				? require(serviceAccountPath)
				: null;

			// Firebase Setup
			admin.initializeApp(
				serviceAccount
					? {
						credential: admin.credential.cert(
							serviceAccount as ServiceAccount
						),
					}
					: {}
			);
			return admin;
		})();
};

export const firebaseAdminProviders: Provider[] = [
	{
		provide: FIREBASE_ADMIN,
		useFactory: fb,
	},
];
