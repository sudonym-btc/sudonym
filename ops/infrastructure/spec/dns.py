from zlib import crc32


def dns(config, cluster_types):

    # We are going to use this type provider all over the place, so get it into a
    # local variable for easy use.
    dnsTypeProvider = "gcp-types/dns-v1"

    # Create the zone.
    zoneName = config["env"] + "-zone"

    domain = ("" if config["env"] != "production" else config["env"] + ".") + config[
        "domain"
    ]
    
    records = [
        {
            "name": "api." + domain + ".",
            "type": "A",
            "ttl": 3600,
            "rrdatas": ["$(ref." + config["env"] + "-ip" + ".address)"],
        },
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
        # GOOGLE DOMAIN EMAIL ETC
        {
            "name": domain + ".",
            "type": "MX",
            "ttl": 300,
            "rrdatas": [
                "1 aspmx.l.google.com.",
                "5 alt1.aspmx.l.google.com.",
                "5 alt2.aspmx.l.google.com.",
                "10 alt3.aspmx.l.google.com.",
                "10 alt4.aspmx.l.google.com.",
            ],
        },
        {
            "name": domain + ".",
            "type": "SPF",
            "ttl": 3600,
            "rrdatas": [
                '"v=spf1 include:_spf.google.com ~all"',
            ],
        },
        {
            "name": domain + ".",
            "type": "TXT",
            "ttl": 3600,
            "rrdatas": [
                '"v=spf1 include:_spf.google.com ~all"',
            ],
        },
        {
            "name": "google._domainkey." + domain + ".",
            "type": "TXT",
            "ttl": 3600,
            "rrdatas": [
                '"v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5fSri/lTTkAQi31waZIucur+3n6ldkOVkqpzIWqIha9cdNICtX2u+fzbqUuSMdWluUtYZ10G4tuo00FFdekSQQbOBTjLYFY3GPgtiktzO+96OJMu7OBf3FwIHoufR0AU3txd3ALrr2l6TBjyR2uvviG+S1QXn39XDDgeiLzGzRMij2GLDO2MRzDxdA5DT2alC" "qIrzC2SI3HWaN5Y3JNyYTE68QhFviGITm+5z1Mhj4lO5Su+mGcGhjjjEAzxcel7jE4hXc1Bget2Km223WKD+ahc7hRe/bsDMfL2S1sTVQFv+PICirZf/jEtyyRjgJa72vaRMmD23lZLC1nvR/bJwQIDAQAB"',
            ],
        },
    ]

    resourceSets = []

    for record in records:

        resourceSets += [
            {
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
            },
        ]

    resources = [
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
        {
            "name": config["env"] + "-ip",
            "type": "compute.v1.globalAddress",
            "properties": {
                "name": config["env"] + "-ip",
                "description": config["env"] + "-ip description",
                "networkTier": "PREMIUM",
                "ipVersion": "IPV4",
            },
        }
        
    ] + resourceSets

    return {"resources": resources}


def GenerateStableResourceRecordSetName(resourceRecordSet):
    return "%(name)s-%(type)s-%(ttl)s-%(rrdataHash)s" % {
        "name": resourceRecordSet["name"],
        "type": resourceRecordSet["type"].lower(),
        "ttl": resourceRecordSet["ttl"],
        "rrdataHash": crc32('\0'.join(resourceRecordSet["rrdatas"]).encode()),
    }
