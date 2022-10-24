export const configProduction = () => {
	console.log(process.env);

	return {
		domain: 'sudonym.app',
		network: 'mainnet',
		database: {
			name: 'app',
			database: 'app',
			dialect: 'mysql',
			host: 'db.sudonym.app',
			username: process.env.MYSQL_USER,
			password: process.env.MYSQL_PASS,
		}
	};
};
