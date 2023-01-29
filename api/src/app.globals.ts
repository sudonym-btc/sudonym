import { INestApplication, Logger } from '@nestjs/common';
import { HttpAdapterHost } from '@nestjs/core';
import { contextRequest } from 'helper/context-request';
import { HttpExceptionFilter } from 'helper/exception.filter';
import { requestLogger } from 'helper/logger';
import { ValidationErrorInterceptor } from 'helper/validation-response.interceptor';
import { AuthService } from 'module/auth/auth.service';
import { WsAdapter } from 'module/events/websocket-adapter';
const logger = new Logger('Global');

export const applyGlobals = (app: INestApplication) => {
	logger.log('Applying global validators and interceptors');
	app.use(contextRequest(app.get(AuthService)));
	app.use(requestLogger);
	app.enableCors({
		origin: true,
		methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
		credentials: true,
	});
	app.useGlobalFilters(new HttpExceptionFilter(app.get(HttpAdapterHost)));
	app.useGlobalInterceptors(new ValidationErrorInterceptor());
	app.useWebSocketAdapter(new WsAdapter(app));
};
