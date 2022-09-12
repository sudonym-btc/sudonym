import { options as cmdargs } from './../command-line-args';
import { configDevelopment } from './config-development';
import { configProduction } from './config-production';
import { configStaging } from './config-staging';
import { config as configTest } from './config-test';

const configs = {
	test: configTest,
	development: configDevelopment,
	staging: configStaging,
	production: configProduction

};

export const getConfig = () => {
	return {
		...config,
		...configs[process.env.NODE_ENV || 'development']
	};
};

export const config = {
	env: 'development',
	selfUrl: cmdargs.selfUrl ? cmdargs.selfUrl : 'https://api.' + getConfig().domain,
	lightningREST: cmdargs.lightning ? cmdargs.lightning : getConfig().env + '-c-lightning-rest-service',
	bitcoinMQ: cmdargs.bitcoinMQ ? cmdargs.bitcoinMQ.replace('https', 'tcp') : getConfig().env + '-bitcoin-zeromq-service',
	macaroonFile: './certs/access.macaroon',
	database: {
		name: 'app',
		user: 'user',
		password: 'password',
		host: cmdargs.dbHost || 'localhost',
		dialect: 'mysql',
	}
};