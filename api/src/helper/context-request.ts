import * as cls from 'cls-hooked';
import { Request, Response, NextFunction } from 'express';
import { AuthService } from 'src/module/auth/auth.service';

export const requestContextCls = cls.createNamespace("context");
export function contextRequest(request: Request, response: Response, next: NextFunction) {
    requestContextCls.run(async () => {
        const req = {
            auth: await new AuthService().auth(request.headers["x-access-token"] as string)
        };
    
        requestContextCls.set('request', req);
    
        next();
    })
};