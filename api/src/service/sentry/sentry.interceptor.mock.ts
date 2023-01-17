import {
	CallHandler,
	ExecutionContext,
	Injectable,
	NestInterceptor,
	Scope,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { SentryService } from './sentry.service';

/**
 * We must be in Request scope as we inject SentryService
 */
@Injectable({ scope: Scope.REQUEST })
export class MockSentryInterceptor implements NestInterceptor {
	constructor(private sentryService: SentryService) {}

	intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
		return next.handle();
	}
}
