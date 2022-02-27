config = {
    "default": {
        "project": "sudonym-lightning-test",
        "zone": "us-central1-c",
        "domain": "sudonym.app",
    },
    "production": {
        "env": "production",
    },
    "staging": {
        "env": "staging",
    },
    "test": {
        "env": "test",
    },
    "development": {
        "env": "development",
    }
}


def getConfig(environment):
    return {**config["default"], **config[environment]}
