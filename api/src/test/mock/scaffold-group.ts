import { Config } from 'config/config';
import { createMockApp, mockScaffold } from './create-mock-entities';

export const scaffoldGroup = (
	description,
	callback: (scaffold: mockScaffold) => any
) => {
	return describe(description, () => {
		const scaffold: mockScaffold = {} as any;

		const closeApp = async () => {
			await scaffold.app
				.get('SEQUELIZE')
				.query(
					'DROP DATABASE `' +
						scaffold.app.get(Config).database.database +
						'`;'
				);
			await scaffold.app.close();
		};

		const wipeDB = async () => {
			// console.log(await scaffold.app.get('SEQUELIZE').close());
			await scaffold.app.get('SEQUELIZE').transaction(async (t) => {
				const options = { raw: true, transaction: t };
				await scaffold.app
					.get('SEQUELIZE')
					.query('SET FOREIGN_KEY_CHECKS = 0', options);
				await scaffold.app
					.get('SEQUELIZE')
					.truncate({ cascade: true, ...options });
				await scaffold.app
					.get('SEQUELIZE')
					.query('SET FOREIGN_KEY_CHECKS = 1', options);
			});
		};

		beforeAll(async () => {
			scaffold.app = await createMockApp();
		}, 45000);

		beforeEach(() => {
			jest.clearAllMocks();
			jest.resetAllMocks();
		});

		afterAll(async () => {
			await closeApp();
		});

		callback(scaffold);
	});
};
