import { sequelize } from './sequelize';
import * as mocks from '@sudonym/models/src/mock';

export const seed = async () => {
	await sequelize.sync({ force: true });
	await sequelize.models.Pot.bulkCreate(mocks.pot.mocks as any);
	await sequelize.models.User.bulkCreate(mocks.user.mocks as any);
	await sequelize.models.Transaction.bulkCreate(mocks.transaction.mocks as any);
};
seed();