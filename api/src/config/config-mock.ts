import { v4 as uuid } from 'uuid';

export const configMock = () => ({
	domain: 'mock.sudonym.app',
	network: 'mainnet',
	database: {
		database: 'app-' + uuid().substring(0, 8),
		dialect: 'mysql',
		host: '127.0.0.1',
		username: process.env.DB_USER || 'root',
		password: false,
	},
});
