import * as cls from 'cls-hooked';
import { NextFunction, Request, Response } from 'express';
import { AuthService } from 'module/auth/auth.service';
import { User } from 'module/user/user.model';

export const context = cls.createNamespace('context');
export const contextRequest =
	(authService: AuthService) =>
	(request: Request, response: Response, next: NextFunction) => {
		context.run(async () => {
			const req = {
				auth: await authService.auth({
					token: request.headers['x-access-token'] as string,
				}),
			};

			context.set('request', req);

			next();
		});
	};

export const authUserIdGetter = () => context.get('request')?.auth?.uid;
export const runAsUser = <CB>(
	user: Partial<User>,
	cb: () => Promise<CB>
): Promise<CB> => {
	return context.runAndReturn(async () => {
		const req = {
			auth: {
				uid: user.id,
			},
		};

		context.set('request', req);
		return await cb();
	});
};
