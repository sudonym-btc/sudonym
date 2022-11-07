import { Inject } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { AuthService } from 'module/auth/auth.service';

export class MockAuthService extends AuthService {
	@Inject() jwtService: JwtService;
	async auth({ token }: { token: string }) {
		if (!token) return null;
		return await this.jwtService.verify(token);
	}
}
