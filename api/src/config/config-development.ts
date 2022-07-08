
export const configDevelopment = {
    domain: 'local.development',
    lightningREST: 'https://lightning-rest.local.development',
    bitcoinMQ: 'tcp://bitcoin-mq.local.development:5555',
    database: {
        name: 'app',
        dialect: 'sqlite',
        storage: './database.sqlite'
    }
}