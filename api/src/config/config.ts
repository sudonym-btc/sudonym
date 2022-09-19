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

const env = process.env.NODE_ENV || 'development';

export const getConfig = () => {
	return {
		...config,
		...configs[env],
	};
};

export const config = {
	env,
	selfUrl: cmdargs.selfUrl
		? cmdargs.selfUrl
		: 'https://api.' + getConfig().domain,
	lightningREST: cmdargs.lightning
		? cmdargs.lightning
		: 'http://' +
		  env +
		  '-c-lightning-rest-service.default.svc.cluster.local:3001',
	bitcoinMQ: cmdargs.bitcoinMQ
		? cmdargs.bitcoinMQ.replace('https', 'tcp')
		: 'tcp://' +
		  env +
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

console.log(getConfig());
