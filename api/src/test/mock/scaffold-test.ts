import {
	createMockEntities,
	mockEntities,
	mockScaffold,
} from './create-mock-entities';

export const scaffoldTest = (
	scaffold: mockScaffold,
	description,
	callback: (entities: mockEntities) => any
) => {
	return it(description, async () => {
		await callback(await createMockEntities(scaffold.app));
	});
};
