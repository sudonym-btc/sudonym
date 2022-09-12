import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { AuthService } from 'src/module/auth/auth.service';
import { requestContextCls } from './context-request';

export const ParseRequest = createParamDecorator(
	async (data: unknown, ctx: ExecutionContext) => {
		const request = ctx.switchToHttp().getRequest();
		const req = {
			auth: requestContextCls.get('request')?.auth || await new AuthService().auth(request.headers['x-access-token'])
		};
		return req;
	},
);

export class RequestType {
  auth: {
    uid: number
  }
}