import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { WsAdapter } from './module/events/websocket-adapter';
import { requestLogger } from './helper/logger';
import { contextRequest } from './helper/context-request';
import { downloadFiles } from './helper/config-loader';

async function bootstrap() {

	await downloadFiles();
	const app = await NestFactory.create(AppModule);
	app.useWebSocketAdapter(new WsAdapter(app));
	app.use(requestLogger);
	app.use(contextRequest);

  
	const config = new DocumentBuilder()
		.setTitle('Sudonym')
		.setDescription('Sudonym API')
		.setVersion('0.0.1')
		.addTag('sudonym')
		.build();
	const document = SwaggerModule.createDocument(app, config);
	SwaggerModule.setup('api', app, document);

	await app.listen(3000);
}
bootstrap();