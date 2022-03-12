config = {
    "default": {
        "project": "sudonym-lightning-test",
        "zone": "us-central1-c",
        "domain": "sudonym.app",
    },
    "production": {
        "env": "production",
        "domain": "sudonym.app",
    },
    "staging": {
        "env": "staging",
        "domain": "sudonym.app",
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
