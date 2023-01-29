import {
	ArgumentsHost,
	Catch,
	ExceptionFilter,
	HttpAdapterHost,
	HttpException,
	HttpStatus,
} from '@nestjs/common';
import { AppError } from '@sudonym/models';

@Catch()
export class HttpExceptionFilter implements ExceptionFilter {
	constructor(private readonly httpAdapterHost: HttpAdapterHost) {}

	catch(exception: unknown, host: ArgumentsHost): void {
		// In certain situations `httpAdapter` might not be available in the
		// constructor method, thus we should resolve it here.
		const { httpAdapter } = this.httpAdapterHost;

		const ctx = host.switchToHttp();

		const httpStatus =
			exception instanceof HttpException
				? exception.getStatus()
				: HttpStatus.INTERNAL_SERVER_ERROR;

		const responseBody =
			exception instanceof AppError
				? exception
				: {
						statusCode: httpStatus,
						timestamp: new Date().toISOString(),
						path: httpAdapter.getRequestUrl(ctx.getRequest()),
				  };

		httpAdapter.reply(ctx.getResponse(), responseBody, httpStatus);
	}
}
