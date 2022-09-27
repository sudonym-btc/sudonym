import {
	createMockApp,
	createMockEntities,
	mockScaffold,
} from './create-mock-entities';

export const scaffoldGroup = (
	description,
	callback: (scaffold: mockScaffold) => any
) => {
	return describe(description, () => {
		const scaffold: mockScaffold = {} as any;

		beforeAll(async () => {
		});

		beforeEach(async () => {
			scaffold.app = await createMockApp();
			await scaffold.app.get('SEQUELIZE').truncate({ cascade: true });
			scaffold.entities = await createMockEntities();
		});

		afterEach(async () => {
			await scaffold.app.close();
		})

		

		callback(scaffold);
	});
};
