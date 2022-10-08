import * as cls from 'cls-hooked';
import { Request, Response, NextFunction } from 'express';
import { AuthService } from 'module/auth/auth.service';

export const requestContextCls = cls.createNamespace('context');
export const contextRequest =
	(authService: AuthService) =>
	(request: Request, response: Response, next: NextFunction) => {
		requestContextCls.run(async () => {
			const req = {
				auth: await authService.auth({
					token: request.headers['x-access-token'] as string,
				}),
			};

			requestContextCls.set('request', req);

			next();
		});
	};
