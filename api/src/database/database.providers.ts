import { sequelize } from './sequelize';

export const databaseProviders = [
	{
		provide: 'SEQUELIZE',
		useFactory: async () => {
			await sequelize.sync({ force: false });
			return sequelize;
		},
	},
];
