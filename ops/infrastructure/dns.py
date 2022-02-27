def dns(config, cluster_types):

    # We are going to use this type provider all over the place, so get it into a
    # local variable for easy use.
    dnsTypeProvider = "gcp-types/dns-v1"

    # Create the zone.
    zoneName = config["env"] + "-zone"

    domain = ("" if config["env"] != "production" else config["env"] + ".") + config["domain"]

    records = [
        {
            "name": "rtl." + domain + ".",
            "type": "A",
            "ttl": 3600,
            "rrdatas": ["$(ref." + config["env"] + "-ip" + ".address)"],
        },
        {
            "name": "app." + domain + ".",
            "type": "A",
            "ttl": 3600,
            "rrdatas": ["$(ref." + config["env"] + "-ip" + ".address)"],
        },
        {
            "name": domain + ".",
            "type": "A",
            "ttl": 3600,
            "rrdatas": ["$(ref." + config["env"] + "-ip" + ".address)"],
        },
    ]

    resourceSets = []

    for record in records:

        resourceSets += [{
            "name": "%(stableName)s-create"
            % {"stableName": GenerateStableResourceRecordSetName(record)},
            "action": "%(dnsTypeProvider)s:dns.changes.create"
            % {"dnsTypeProvider": dnsTypeProvider},
            "metadata": {
                "dependsOn": [zoneName],
                "runtimePolicy": [
                    "CREATE",
                ],
            },
            "properties": {
                "managedZone": "$(ref.%(zoneName)s.name)" % {"zoneName": zoneName},
                "additions": [record],
            },
        },
        # Change to delete it.
        {
            "name": "%(stableName)s-delete"
            % {"stableName": GenerateStableResourceRecordSetName(record)},
            "action": "%(dnsTypeProvider)s:dns.changes.create"
            % {"dnsTypeProvider": dnsTypeProvider},
            "metadata": {
                "dependsOn": [zoneName],
                "runtimePolicy": [
                    "DELETE",
                ],
            },
            "properties": {
                "managedZone": "$(ref.%(zoneName)s.name)" % {"zoneName": zoneName},
                "deletions": [record],
            },
        }]


    resources = [
        {
            "name": config["env"] + "-ip",
            "type": "compute.v1.globalAddress",
            "properties": {
                "name": config["env"] + "-ip",
                "description": config["env"] + "-ip description",
                "networkTier": "PREMIUM",
                "ipVersion": "IPV4",
            },
        },
        {
            "name": zoneName,
            "type": "dns.v1.managedZone",
            "properties": {
                "cloudLoggingConfig": {"enableLogging": False},
                "description": "Main Zone for " + config["env"],
                "dnsName": config["domain"] + ".",
                "name": zoneName,
                "visibility": "public",
            },
        },
    ] + resourceSets
    
    return {"resources": resources}


def GenerateStableResourceRecordSetName(resourceRecordSet):
    return "%(name)s-%(type)s-%(ttl)s-%(rrdataHash)s" % {
        "name": resourceRecordSet["name"],
        "type": resourceRecordSet["type"].lower(),
        "ttl": resourceRecordSet["ttl"],
        "rrdataHash": "".join(resourceRecordSet["rrdatas"]),
    }
