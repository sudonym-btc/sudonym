export const configTest = () => ({
	domain: 'test.sudonym.app',
	database: {
		database: 'app',
		dialect: 'mysql',
		host: 'test-db-service',
		username: process.env.DB_USER || 'root',
		password: process.env.DB_PASS || 'testing',
	},
});
