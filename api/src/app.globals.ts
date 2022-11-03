import {
	BadRequestException,
	INestApplication,
	Logger,
	ValidationPipe,
} from '@nestjs/common';
import { ValidationError } from 'class-validator';
import { contextRequest } from 'helper/context-request';
import { requestLogger } from 'helper/logger';
import { ValidationErrorInterceptor } from 'helper/validation-response.interceptor';
import { AuthService } from 'module/auth/auth.service';
import { WsAdapter } from 'module/events/websocket-adapter';
const logger = new Logger('Global');

export const applyGlobals = (app: INestApplication) => {
	logger.log('Applying global validators and interceptors');
	app.useGlobalPipes(
		new ValidationPipe({
			whitelist: true,
			transform: true,
			exceptionFactory: (validationErrors: ValidationError[] = []) =>
				new BadRequestException(validationErrors),
		})
	);
	app.useGlobalInterceptors(new ValidationErrorInterceptor());
	app.useWebSocketAdapter(new WsAdapter(app));
	app.use(requestLogger);
	app.use(contextRequest(app.get(AuthService)));
	app.enableCors({
		origin: true,
		methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
		credentials: true,
	});
};
