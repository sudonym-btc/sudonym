config = {
    "default": {
        "project": "sudonym-lightning-test",
        "zone": "us-central1-c",
        "domain": "sudonym.app",
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
        "domain": "staging.sudonym.app",
        "network": "regtest",

    },
    "development": {
        "project": "sudonym-lightning-test",
        "env": "development",
        "domain": "local.development",
        "network": "regtest",
        "bitcoin": {
            "rpcPort": 8332,
            "port": 8333
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
        }
    }
}


def getConfig(environment):
    return {**config["default"], **config[environment]}
