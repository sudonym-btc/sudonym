import { Inject, Injectable } from '@nestjs/common';
import * as crypto from 'crypto';
import admin, { ServiceAccount } from 'firebase-admin';
import { UserService } from '../user/user.service';
import * as serviceAccount from '../../../service-account.json';
import { AuthError } from './types/error';
// Firebase Setup
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount as ServiceAccount)
});

@Injectable()
export class AuthService {

    // @Inject(UserService) private readonly userService: UserService;

    async auth(request: Request) {

        if(!request.headers['x-access-token']) return null;
        return await admin.auth().verifyIdToken(request.headers['x-access-token']);
        // try {
        //     const user = await this.userService.findOne({
        //         where: {
        //             passHash: hash(pass)
        //         }
        //     });
        //     return await admin.auth().createCustomToken(user.id.toString());
        // } catch (e) {
        //     throw new AuthError(e.toString());
        // }
    }
}

export const hash = (str: string) => {
    return crypto.createHash('md5').update(str).digest('hex');
}