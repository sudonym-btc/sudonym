import { options as cmdargs } from './../command-line-args';
import { config as configTest } from './config.test';

const configs = {
    test: configTest
}
export const config = {
    lightningREST: cmdargs.lightning,
    database: {
        name: 'app',
        user: 'user',
        password: 'password',
        host: cmdargs.dbHost || 'localhost',
        // Use "sqlite" for "test", the connection settings above are ignored
        dialect: 'mysql',
    }
}

export const getConfig = () => {
    return {
        ...config,
        ...configs[process.env.NODE_ENV || 'test']
    }
}