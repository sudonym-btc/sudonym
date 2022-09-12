import { INestApplication } from '@nestjs/common';
import { Test } from '@nestjs/testing';
import { AppModule } from '../../app.module';
import { User } from '../../module/user/user.model';
import { createUsers } from './user';

export type mockScaffold = {
	app: INestApplication;
	entities: {
		user: User[];
	};
};

export const createMockApp = async () => {
	const moduleFixture = await Test.createTestingModule({
		imports: [AppModule],
	}).compile();

	const app = moduleFixture.createNestApplication();
	await app.init();
	return app;
};

export const createMockEntities = async () => {
	return {
		user: await createUsers(),
	};
};
