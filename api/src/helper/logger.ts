import { Logger } from '@nestjs/common';
import { NextFunction, Request, Response } from 'express';

const logger = new Logger('HTTP');
export function requestLogger(
	request: Request,
	response: Response,
	next: NextFunction
) {
	const { ip, method, originalUrl } = request;
	const userAgent = request.get('user-agent') || '';

	response.on('finish', () => {
		const { statusCode } = response;
		const contentLength = response.get('content-length');

		logger.verbose(
			`${method} ${originalUrl} ${statusCode} ${contentLength} - ${userAgent} ${ip}`
		);
	});

	next();
}
