import { Config } from 'config/config';
import {
	createMockApp,
	createMockEntities,
	mockScaffold,
} from './create-mock-entities';
process.on('exit', function () {
	console.log((process as any)._getActiveHandles());
});
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
			// Todo: Allow hooks to complete
			await new Promise((r) => setTimeout(r, 1000));
			// console.log(await scaffold.app.get('SEQUELIZE').close());
			// await scaffold.app.get('SEQUELIZE').transaction(async (t) => {
			// 	const options = { raw: true, transaction: t };
			// 	await scaffold.app
			// 		.get('SEQUELIZE')
			// 		.query('SET FOREIGN_KEY_CHECKS = 0', options);
			// 	await scaffold.app
			// 		.get('SEQUELIZE')
			// 		.truncate({ cascade: true, ...options });
			// 	await scaffold.app
			// 		.get('SEQUELIZE')
			// 		.query('SET FOREIGN_KEY_CHECKS = 1', options);
			// });
		};

		beforeEach(async () => {
			scaffold.app = await createMockApp();
			scaffold.entities = await createMockEntities(scaffold.app);
		}, 30000);

		afterEach(async () => {
			await wipeDB();
			await closeApp();
		}, 30000);

		callback(scaffold);
	});
};
