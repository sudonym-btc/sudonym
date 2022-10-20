export const configDevelopment = {
	domain: 'local.development',
	database: {
		name: 'app',
		dialect: 'mysql',
		host: 'development-db-service',
		username: 'root',
		password: 'testing',
		database: 'test',
	},
	// database: {
	// 	name: 'app',
	// 	dialect: 'sqlite',
	// 	storage: './database.sqlite',
	// },
};
