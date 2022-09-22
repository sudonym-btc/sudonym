config = {
    "default": {
        "project": "sudonym-lightning-test",
        "zone": "us-central1-c",
        "domain": "sudonym.app",
        "bitcoin": {
            "rpcPort": 8332,
            "port": 8333,
        },
        "lightning": {
            "port": 9735
        },
        "lightningRest": {
            "docPort": 4001,
            "port": 3001
        },
        "rtl": {
            "port": 3000
        },
        "api": {
            "port": 3000,
            "websocketPort": 3001
        },
        "backup": True,
    },
    "production": {
        "project": "sudonym-lightning-test",
        "env": "production",
        "domain": "sudonym.app",
        "network": "mainnet"

    },
    "staging": {
        "project": "sudonym-lightning-test",
        "env": "staging",
        "domain": "staging.sudonym.app",
        "network": "mainnet"
        
    },
    "test": {
        "project": "sudonym-lightning-test",
        "env": "test",
        "domain": "test.sudonym.app",
        "network": "regtest",
        "backup": False,

    },
    "development": {
        "project": "sudonym-lightning-test",
        "env": "development",
        "domain": "local.development",
        "network": "regtest",
        "backup": False,
    }
}


def getConfig(environment):
    return {**config["default"], **config[environment]}
