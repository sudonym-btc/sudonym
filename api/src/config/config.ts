import { options as cmdargs } from '../cmd-line-args';
import { configDevelopment } from './config-development';
import { configProduction } from './config-production';
import { configStaging } from './config-staging';
import { configTest } from './config-test';
import { configMock } from './config-mock';
import { SequelizeOptions } from 'sequelize-typescript';

const configs = {
	mock: configMock,
	development: configDevelopment,
	test: configTest,
	staging: configStaging,
	production: configProduction,
};

const env = process.env.NODE_ENV || 'development';

export const getConfig = () => {
	const c = {
		...new Config(),
		...configs[env](),
	};
	c.selfUrl = 'https://api.' + c.domain;
	return c;
};

export class Config {
	env = env;
	network = 'regtest';
	domain = 'sudonym.app';
	selfUrl: string;
	lightningREST = cmdargs.lightning
		? cmdargs.lightning
		: 'http://' +
		  env +
		  '-c-lightning-rest-service.default.svc.cluster.local:3001';
	bitcoinMQ = cmdargs.bitcoinMQ
		? cmdargs.bitcoinMQ.replace('https', 'tcp')
		: 'tcp://' +
		  env +
		  '-bitcoin-zeromq-service.default.svc.cluster.local:5555';
	macaroonFile = './certs/access.macaroon';
	database: SequelizeOptions = {
		dialect: 'sqlite',
	}
	wsPort = env == 'mock' ? Math.floor(Math.random() * 60000) + 1000 : 3001;
};
