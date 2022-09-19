import { options as cmdargs } from '../cmd-line-args';
import { configDevelopment } from './config-development';
import { configProduction } from './config-production';
import { configStaging } from './config-staging';
import { config as configTest } from './config-test';

const configs = {
	test: configTest,
	development: configDevelopment,
	staging: configStaging,
	production: configProduction,
};

// console.log(process.env);
// process.exit();
export const getConfig = () => {
	return {
		...config,
		...configs[process.env.NODE_ENV || 'development'],
	};
};

export const config = {
	env: process.env.NODE_ENV || 'development',
	selfUrl: cmdargs.selfUrl
		? cmdargs.selfUrl
		: 'https://api.' + getConfig().domain,
	lightningREST: cmdargs.lightning
		? cmdargs.lightning
		: 'http://' +
		  getConfig().env +
		  '-c-lightning-rest-service.default.svc.cluster.local:3001',
	bitcoinMQ: cmdargs.bitcoinMQ
		? cmdargs.bitcoinMQ.replace('https', 'tcp')
		: 'tcp://' +
		  getConfig().env +
		  '-bitcoin-zeromq-service.default.svc.cluster.local:5555',
	macaroonFile: './certs/access.macaroon',
	database: {
		name: 'app',
		user: 'user',
		password: 'password',
		host: cmdargs.dbHost || 'localhost',
		dialect: 'mysql',
	},
};
