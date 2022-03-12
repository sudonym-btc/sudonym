import { createMockApp, createMockEntities, mockScaffold } from "./create-mock-entities";

export const scaffoldGroup = (description, callback: (scaffold: mockScaffold) => any) => {
    return describe(description, () => {
        let scaffold: mockScaffold = {} as any;

        beforeAll(async () => {
            scaffold.app = await createMockApp();
        });

        beforeEach(async () => {
            await scaffold.app.get('SEQUELIZE').truncate({ cascade: true });
            scaffold.entities = await createMockEntities();
        });

        callback(scaffold);
    })
};