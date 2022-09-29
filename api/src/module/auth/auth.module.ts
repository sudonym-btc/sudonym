import { Global, Module } from '@nestjs/common';
import { firebaseAdminProviders } from 'service/firebase-admin/firebase-admin';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';

@Global()
@Module({
	imports: [],
	controllers: [AuthController],
	providers: [...firebaseAdminProviders, AuthService],
	exports: [...firebaseAdminProviders, AuthService],
})
export class AuthModule {}
