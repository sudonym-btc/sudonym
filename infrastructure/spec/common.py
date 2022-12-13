config = {
    "default": {
        "appName": "sudonym",
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
        "cluster": {
            "machineType": "e2-standard-2",
            "diskSizeGb": 100
        },
        "db": {
            "tier": "db-f1-micro",
            "backup": False
        },
        "backup": True,
        "loglevel": "debug"
    },
    "production": {
        "project": "sudonym-lightning-production",
        "env": "production",
        "domain": "sudonym.app",
        "network": "mainnet",
        "loglevel": "info",
        "db": {
            "tier": "db-f1-micro",
            "backup": True
        },
    },
    "staging": {
        "project": "sudonym-lightning-staging",
        "env": "staging",
        "domain": "staging.sudonym.app",
        "network": "mainnet",
        "loglevel": "info",
        "cluster": {
            "machineType": "t2d-standard-1",
            "diskSizeGb": 100
        },
    },
    "test": {
        "project": "sudonym-lightning-test",
        "env": "test",
        "domain": "test.sudonym.app",
        "network": "regtest",
        "loglevel": "info",
        "cluster": {
            "machineType": "t2d-standard-1",
            "diskSizeGb": 100
        },
        "backup": False
    },
    "development": {
        "project": "sudonym-lightning-test",
        "env": "development",
        "domain": "local.development",
        "loglevel": "debug",
        "network": "regtest",
        "backup": False,
    }
}

def getConfig(environment):
    return {**config["default"], **config[environment]}
