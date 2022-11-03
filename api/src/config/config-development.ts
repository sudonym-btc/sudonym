export const configDevelopment = () => ({
	domain: 'local.development',
	database: {
		name: 'app',
		dialect: 'mysql',
		host: 'development-db-service',
		username: 'root',
		password: 'testing',
		database: 'app',
	},
	bitcoin: {
		network: 'regtest',
	},
});
