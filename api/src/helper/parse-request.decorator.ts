import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { requestContextCls } from './context-request';

export const ParseRequest = createParamDecorator(
	async (data: unknown, ctx: ExecutionContext) => {
		const req = {
			auth: requestContextCls.get('request')?.auth,
		};
		return req;
	}
);

export class RequestType {
	auth: {
		uid: number;
	};
}
