import { Inject, Injectable } from '@nestjs/common';
import * as crypto from 'crypto';
import admin, { ServiceAccount } from 'firebase-admin';
import { UserService } from '../user/user.service';
import * as serviceAccount from '../../service-account.json';
import { AuthError } from './types/error';
// Firebase Setup
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount as ServiceAccount)
});

@Injectable()
export class AuthService {

    async auth(token: string) {
        if(!token) return null;
        return await admin.auth().verifyIdToken(token);
    }
}

export const hash = (str: string) => {
    return crypto.createHash('md5').update(str).digest('hex');
}