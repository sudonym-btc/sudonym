export const configProduction = () => {
	return {
		domain: 'sudonym.app',
		network: 'mainnet',
		database: sqlCloudProxy,
	};
};

export const sqlCloudProxy = {
	database: 'app',
	dialect: 'mysql',
	host: '127.0.0.1',
	username: process.env.DB_USER || 'api',
	password: process.env.DB_PASS,
	pool: {
		max: 100,
	},
};
