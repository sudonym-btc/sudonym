export const configProduction = () => ({
	domain: 'sudonym.app',
	network: 'mainnet',
	database: {
		name: 'app',
		dialect: 'mysql',
		host: 'db.sudonym.app',
		username: process.env.MYSQL_USER,
		password: process.env.MYSQL_PASS,
		database: 'test',
	},
});
