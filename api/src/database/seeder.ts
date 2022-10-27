import * as mocks from '@sudonym/models/src/mock';
import { getConfig } from 'config/config';
import { databaseProviders } from './database.providers';

export const seed = async () => {
	const sequelize = await databaseProviders[0].useFactory(getConfig());

	await sequelize.sync({ force: true });
	await sequelize.models.Pot.bulkCreate(mocks.pot.mocks as any);
	await sequelize.models.User.bulkCreate(mocks.user.mocks as any);
	await sequelize.models.Transaction.bulkCreate(
		mocks.transaction.mocks as any
	);
};
seed();
