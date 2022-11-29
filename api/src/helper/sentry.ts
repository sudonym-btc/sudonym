import { ConsoleLogger, LogLevel } from '@nestjs/common';
import * as Sentry from '@sentry/node';
import { getConfig } from 'config/config';
Sentry.init({
	dsn: 'REDACTED_SENTRY_DSN',
	environment: getConfig().env,

	// Set tracesSampleRate to 1.0 to capture 100%
	// of transactions for performance monitoring.
	// We recommend adjusting this value in production
	tracesSampleRate: 1.0,
});

export class SentryLogger extends ConsoleLogger {
	constructor() {
		super();
		this.setLogLevels([
			...(['mock', 'development'].includes(getConfig().env)
				? ['verbose']
				: []),
			'error',
			'warn',
			'log',
			'debug',
		] as LogLevel[]);
	}
	/**
	 * Write a 'log' level log.
	 */
	log(message: any, ...optionalParams: any[]) {
		// Sentry.captureMessage(message, 'info');
		super.log(message, ...optionalParams);
	}

	/**
	 * Write an 'error' level log.
	 */
	error(message: any, ...optionalParams: any[]) {
		Sentry.captureException(
			message + ': ' + JSON.stringify(optionalParams)
		);
		super.error(message, ...optionalParams);
	}

	/**
	 * Write a 'warn' level log.
	 */
	warn(message: any, ...optionalParams: any[]) {
		Sentry.captureException(
			message + ': ' + JSON.stringify(optionalParams)
		);
		super.warn(message, ...optionalParams);
	}

	/**
	 * Write a 'debug' level log.
	 */
	debug(message: any, ...optionalParams: any[]) {
		// Sentry.captureMessage(message, 'debug');
		super.debug(message, ...optionalParams);
	}

	/**
	 * Write a 'verbose' level log.
	 */
	verbose(message: any, ...optionalParams: any[]) {
		// Sentry.captureMessage(message, 'debug');
		super.verbose(message, ...optionalParams);
	}
}
