import { LogLevel } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { applyGlobals } from 'app.globals';
import { getConfig } from 'config/config';
import { AppModule } from './app.module';
import { downloadFiles } from './helper/config-loader';

async function bootstrap() {
	await downloadFiles();
	const app = await NestFactory.create(AppModule, {
		logger: [
			...(['mock', 'development'].includes(getConfig().env)
				? ['verbose']
				: []),
			'error',
			'warn',
			'log',
			'debug',
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
