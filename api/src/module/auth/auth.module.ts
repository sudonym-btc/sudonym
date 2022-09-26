import { Module } from '@nestjs/common';
import { firebaseAdminProviders } from 'service/firebase-admin/firebase-admin';
import { UserModule } from '../user/user.module';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';

@Module({
	imports: [UserModule],
	controllers: [AuthController],
	providers: [...firebaseAdminProviders, AuthService],
	exports: [...firebaseAdminProviders],
})
export class AuthModule {}
