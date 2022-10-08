import { Inject, Injectable } from '@nestjs/common';
import {
	FIREBASE_ADMIN,
	T_FIREBASE_ADMIN,
} from 'service/firebase-admin/firebase-admin';

@Injectable()
export class AuthService {
	@Inject(FIREBASE_ADMIN) private firebaseAdmin: T_FIREBASE_ADMIN;

	async auth({ token }: { token: string }) {
		if (!token) return null;
		return await this.firebaseAdmin.auth().verifyIdToken(token);
	}
}
