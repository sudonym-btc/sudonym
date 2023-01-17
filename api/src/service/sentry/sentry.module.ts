import { Module } from '@nestjs/common';
import { APP_INTERCEPTOR } from '@nestjs/core';
import * as Sentry from '@sentry/node';
import { SentryInterceptor } from './sentry.interceptor';
import { MockSentryInterceptor } from './sentry.interceptor.mock';
import { SentryService } from './sentry.service';

export const SENTRY_OPTIONS = 'SENTRY_OPTIONS';

@Module({
	providers: [SentryService],
})
export class SentryModule {
	static forRoot(options: Sentry.NodeOptions) {
		if (process.env.NODE_ENV !== 'mock')
			// initialization of Sentry, this is where Sentry will create a Hub
			Sentry.init(options);

		return {
			module: SentryModule,
			providers: [
				{
					provide: SENTRY_OPTIONS,
					useValue: options,
				},
				SentryService,
				{
					provide: APP_INTERCEPTOR,
					useClass:
						process.env.NODE_ENV == 'mock'
							? MockSentryInterceptor
							: SentryInterceptor,
				},
			],
			exports: [SentryService],
		};
	}
}
