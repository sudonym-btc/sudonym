export const configProduction = () => {
	return {
		domain: 'sudonym.app',
		network: 'mainnet',
		database: {
			name: 'app',
			database: process.env.DB_USER || 'app',
			dialect: 'mysql',
			host: '127.0.0.1',
			username: process.env.DB_USER || 'api',
			password: process.env.DB_PASS,
		}
	};
};
