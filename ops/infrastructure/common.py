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
    },
    "staging": {
        "project": "sudonym-lightning-test",
        "env": "staging",
        "domain": "staging.sudonym.app",
    },
    "test": {
        "env": "test",
    },
    "development": {
        "env": "development",
        "domain": "local.app",
    }
}


def getConfig(environment):
    return {**config["default"], **config[environment]}
