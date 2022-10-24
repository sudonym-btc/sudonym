export const configProduction = () => {
	console.log(process.env);

	return {
		domain: 'sudonym.app',
		network: 'mainnet',
		database: {
			name: 'app',
			database: 'app',
			dialect: 'mysql',
			host: '127.0.0.1',
			username: process.env.MYSQL_USER,
			password: process.env.MYSQL_PASS,
		}
	};
};
