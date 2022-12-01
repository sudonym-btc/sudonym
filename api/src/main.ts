import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { applyGlobals } from './app.globals';
import { AppModule } from './app.module';
import { downloadFiles } from './helper/config-loader';
import { SentryLogger } from './helper/sentry';

async function bootstrap() {
	console.log('Booting app');
	await downloadFiles();
	const app = await NestFactory.create(AppModule, {
		logger: new SentryLogger(),
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
