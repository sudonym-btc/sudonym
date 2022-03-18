import { options as cmdargs } from './../command-line-args';
import { configDevelopment } from './config-development';
import { config as configTest } from './config-test';

const configs = {
    test: configTest,
    development: configDevelopment
}
export const config = {
    lightningREST: cmdargs.lightning,
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