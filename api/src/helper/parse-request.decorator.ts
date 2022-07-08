import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { AuthService } from 'src/module/auth/auth.service';

export const ParseRequest = createParamDecorator(
  (data: unknown, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest();
    return {
      auth: new AuthService().auth(request)
    };
  },
);

export class RequestType {
  auth: {
    uid: number
  }
}