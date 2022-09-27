import { options as cmdargs } from '../cmd-line-args';
import { configDevelopment } from './config-development';
import { configProduction } from './config-production';
import { configStaging } from './config-staging';
import { config as configTest } from './config-test';
import { v4 as uuid } from 'uuid';

const configs = {
	development: configDevelopment,
	test: configTest,
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
	network: 'regtest',
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
		name: 'app-' + uuid().substring(0, 8),
		dialect: 'sqlite',
	},
	wsPort: env == 'mock' ? Math.floor(Math.random() * 60000) + 1000 : 3001,
};
