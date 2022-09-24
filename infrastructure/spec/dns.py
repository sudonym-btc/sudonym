def dns(config, cluster_types):

    # Create the zone.
    zoneName = config["env"] + "-zone"

    domain = ("" if config["env"] != "production" else config["env"] + ".") + config[
        "domain"
    ]

    resources = [
            {
                "name": config["env"] + "-ip",
                "type": "compute.v1.addresses",
                "properties": {
                    "name": config["env"] + "-ip",
                    "region": "us-central1",
                    "description": config["env"] + "-ip",
                },
            },
            {
                "name": domain + ".",
                "metadata": {"dependsOn": [config["env"] + "-ip"]},
                "type": "gcp-types/dns-v1:resourceRecordSets",
                "properties": {
                    "managedZone": config["env"] + "-zone",
                    "records": [
                        {
                            "name": "rtl." + domain + ".",
                            "type": "A",
                            "ttl": 50,
                            "rrdatas": ["$(ref." + config["env"] + "-ip" + ".address)"],
                        },
                        {
                            "name": "api." + domain + ".",
                            "type": "A",
                            "ttl": 50,
                            "rrdatas": ["$(ref." + config["env"] + "-ip" + ".address)"],
                        },
                        {
                            "name": "app." + domain + ".",
                            "type": "A",
                            "ttl": 50,
                            "rrdatas": ["$(ref." + config["env"] + "-ip" + ".address)"],
                        },
                        {
                            "name": "db." + domain + ".",
                            "type": "A",
                            "ttl": 50,
                            "rrdatas": ["$(ref." + config["env"] + "-ip" + ".address)"],
                        },
                        {
                            "name": domain + ".",
                            "type": "A",
                            "ttl": 50,
                            "rrdatas": ["$(ref." + config["env"] + "-ip" + ".address)"],
                        },
                    ],
                },
            }
    ]

    return {"resources": resources}