import { Body, Controller, Get, HttpCode, Param, Post } from '@nestjs/common';
import { AuthService } from './auth.service';

@Controller('auth')
export class AuthController {
	constructor(private readonly authService: AuthService) {}

	@HttpCode(200)
	@Post('')
	auth(@Body('pass') pass) {
		return this.authService.auth({ token: pass });
	}
}
