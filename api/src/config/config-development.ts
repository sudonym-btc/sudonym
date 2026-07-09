export const configDevelopment = () => ({
	domain: 'local.development',
	database: {
		name: process.env.DB_NAME || 'app',
		dialect: 'mysql',
		host: process.env.DB_HOST || '127.0.0.1',
		username: process.env.DB_USER || 'root',
		password: process.env.DB_PASS || '',
		database: process.env.DB_NAME || 'app',
	},
	bitcoin: {
		network: 'regtest',
	},
});
