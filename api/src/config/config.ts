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
    lightningREST: cmdargs.lightning || `${process.env.NODE_ENV}-c-lightning-rest-service`,
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