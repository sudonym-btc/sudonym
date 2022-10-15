import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { downloadFiles } from './helper/config-loader';
import { applyGlobals } from 'app.globals';
import { getConfig } from 'config/config';
import { LogLevel } from '@nestjs/common';

async function bootstrap() {
	await downloadFiles();
	const app = await NestFactory.create(AppModule, {
		logger: [
			...(getConfig().env != "production" ? ['verbose'] : []),
			'error',
			'warn',
			'log',
			'debug'
		] as LogLevel[],
	});
	applyGlobals(app);

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
