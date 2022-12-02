import { Subject } from 'rxjs';
import { SequelizeOptions } from 'sequelize-typescript';
import { options as cmdargs } from '../cmd-line-args';
import { configDevelopment } from './config-development';
import { configMock } from './config-mock';
import { configProduction } from './config-production';
import { configStaging } from './config-staging';
import { configTest } from './config-test';

const configs = {
	mock: configMock,
	development: configDevelopment,
	test: configTest,
	staging: configStaging,
	production: configProduction,
};

const env = process.env.NODE_ENV || 'development';

export const getConfig = () => {
	const config = new Config();
	config.set(configs[env]());
	config.set({
		selfUrl: 'https://api.' + config.domain,
	});
	return config;
};

export class Config {
	onChanged = new Subject();
	constructor(config?: Partial<Config>) {
		this.set(config);
	}
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
	bitcoin = {
		network: 'mainnet',
	};
	macaroonFile = './certs/access.macaroon';
	database: SequelizeOptions = {
		dialect: 'sqlite',
	};
	settle = true;
	intervalSettle = true;
	wsPort = env == 'mock' ? Math.floor(Math.random() * 60000) + 1000 : 3001;
	jwtSecret = 'testing'; // jwtSecret used in testing

	set(config?: Partial<Config>) {
		if (config) {
			Object.assign(this, config);
			this.onChanged.next(true);
		}
	}
}
