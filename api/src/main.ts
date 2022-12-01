import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { applyGlobals } from './app.globals';
import { AppModule } from './app.module';
import { downloadFiles } from './helper/config-loader';
import { SentryLogger } from './helper/sentry';
// eslint-disable-next-line @typescript-eslint/no-var-requires
// const SegfaultHandler = require('segfault-handler');

// SegfaultHandler.registerHandler('crash.log'); // With no argument, SegfaultHandler will generate a generic log file name

// // Optionally specify a callback function for custom logging. This feature is currently only supported for Node.js >= v0.12 running on Linux.
// SegfaultHandler.registerHandler('crash.log', function (signal, address, stack) {
// 	// Do what you want with the signal, address, or stack (array)
// 	// This callback will execute before the signal is forwarded on.
// 	console.log(signal, address, stack);
// });
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
