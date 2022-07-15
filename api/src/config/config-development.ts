export const configDevelopment = {
    domain: 'local.development',
    lightningREST: `http://development-c-lightning-rest-service.default.svc.cluster.local:3001`,
    bitcoinMQ: 'tcp://bitcoin-mq.default.svc.cluster.local:5555',
    database: {
        name: 'app',
        dialect: 'sqlite',
        storage: './database.sqlite'
    }
}