import { Injectable } from '@nestjs/common';
import * as crypto from 'crypto';
import admin, { ServiceAccount } from 'firebase-admin';
import * as fs from 'fs';

const serviceAccountPath = process.cwd() + '/src/service-account.json';
const serviceAccount = fs.existsSync(serviceAccountPath) ? require(serviceAccountPath) : null;
// Firebase Setup
admin.initializeApp(serviceAccount ? {
	credential: admin.credential.cert(serviceAccount as ServiceAccount),
}: {});

@Injectable()
export class AuthService {
	async auth(token: string) {
		if (!token) return null;
		return await admin.auth().verifyIdToken(token);
	}
}

export const hash = (str: string) => {
	return crypto.createHash('md5').update(str).digest('hex');
};
