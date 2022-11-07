import { Global, Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { getConfig } from 'config/config';
import { firebaseAdminProviders } from 'service/firebase-admin/firebase-admin';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';

@Global()
@Module({
	imports: [
		JwtModule.register({
			secret: getConfig().jwtSecret,
		}),
	],
	controllers: [AuthController],
	providers: [...firebaseAdminProviders, AuthService],
	exports: [...firebaseAdminProviders, AuthService],
})
export class AuthModule {}
