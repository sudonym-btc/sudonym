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

}
export const config = {
    lightningREST: cmdargs.lightning ? cmdargs.lightning : process.env.DOCKER ? `${process.env.NODE_ENV}-c-lightning-rest-service` : 'wss://localhost:3001',
    bitcoinMQ: cmdargs.bitcoinMQ ? cmdargs.bitcoinMQ.replace('https', 'tcp') : `${process.env.NODE_ENV}-bitcoin-zeromq-service`,
    macaroonFile: './certs/access.macaroon',
    database: {
        name: 'app',
        user: 'user',
        password: 'password',
        host: cmdargs.dbHost || 'localhost',
        dialect: 'mysql',
    }
}

export const getConfig = () => {
    return {
        ...config,
        ...configs[process.env.NODE_ENV || 'development']
    }
}