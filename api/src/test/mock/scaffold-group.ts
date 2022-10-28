import { Config } from 'config/config';
import {
	createMockApp,
	createMockEntities,
	mockScaffold,
} from './create-mock-entities';
process.on('exit', function() {
	console.log((process as any)._getActiveHandles());
  });
export const scaffoldGroup = (
	description,
	callback: (scaffold: mockScaffold) => any
) => {
	return describe(description, () => {
		const scaffold: mockScaffold = {} as any;

		const closeApp = async () => {
			await scaffold.app.get('SEQUELIZE').query('DROP DATABASE `' + scaffold.app.get(Config).database.database + '`;');
			await scaffold.app.close();
		};

		const wipeDB = async () => {
			await scaffold.app.get('SEQUELIZE').transaction(async t => {
				var options = { raw: true, transaction: t }
				await scaffold.app.get('SEQUELIZE').query('SET FOREIGN_KEY_CHECKS = 0', options);
				await scaffold.app.get('SEQUELIZE').truncate({ cascade: true });
				await scaffold.app.get('SEQUELIZE').query('SET FOREIGN_KEY_CHECKS = 1', options);
			})
		}

		beforeEach(async () => {
			scaffold.app = await createMockApp();
			scaffold.entities = await createMockEntities(scaffold.app as any);
		});

		afterEach(async () => {
			await wipeDB();
			await closeApp();
		})

		callback(scaffold);
	});
};
