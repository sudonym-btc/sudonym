def dns(config, cluster_types):

    # Create the zone.
    zoneName = config["env"] + "-zone"

    domain = ("" if config["env"] != "production" else config["env"] + ".") + config[
        "domain"
    ]

    mainZone = "production-zone"
    mainDomain = ".".join(domain.split(".")[-2:])

    resources = (
        [
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
            #  Create a zone for the root url
            {
                "name": mainZone,
                "type": "gcp-types/dns-v1:managedZones",
                "properties": {
                    "description": "A managed zone",
                    "dnsName": mainDomain + ".",
                },
            },
        ]
        # Create a separate zone for the subdomain if we are not in production
        + (
            [
                {
                    "name": zoneName,
                    "type": "gcp-types/dns-v1:managedZones",
                    "properties": {
                        "description": "A managed zone",
                        "dnsName": domain + ".",
                    },
                },
            ]
            if mainZone != zoneName
            else []
        )
        + [
            {
                "name": domain + ".",
                "metadata": {"dependsOn": [zoneName]},
                "type": "gcp-types/dns-v1:resourceRecordSets",
                "properties": {
                    "managedZone": "$(ref." + zoneName + ".name)",
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
                            "name": domain + ".",
                            "type": "A",
                            "ttl": 50,
                            "rrdatas": ["$(ref." + config["env"] + "-ip" + ".address)"],
                        },
                    ],
                },
            },
            {
                "name": mainDomain + ".",
                "metadata": {"dependsOn": [mainZone]},
                "type": "gcp-types/dns-v1:resourceRecordSets",
                "properties": {
                    "managedZone": "$(ref." + mainZone + ".name)",
                    "records": [
                        # {
                        #     "name": "test." + mainDomain + ".",
                        #     "rrdatas": [
                        #         "ns-cloud-d1.googledomains.com.",
                        #         "ns-cloud-d2.googledomains.com..",
                        #         "ns-cloud-d3.googledomains.com.",
                        #         "ns-cloud-d4.googledomains.com."
                        #     ],
                        #     "ttl": 60,
                        #     "type": "NS",
                        # },
                        # {
                        #     "name": "staging." + mainDomain + ".",
                        #     "rrdatas": [
                        #         "ns-cloud-d1.googledomains.com.",
                        #         "ns-cloud-d2.googledomains.com..",
                        #         "ns-cloud-d3.googledomains.com.",
                        #         "ns-cloud-d4.googledomains.com."
                        #     ],
                        #     "ttl": 60,
                        #     "type": "NS",
                        # },
                        {
                            "name": mainDomain + ".",
                            "rrdatas": [
                                "1 aspmx.l.google.com.",
                                "5 alt1.aspmx.l.google.com.",
                                "5 alt2.aspmx.l.google.com.",
                                "10 alt3.aspmx.l.google.com.",
                                "10 alt4.aspmx.l.google.com.",
                            ],
                            "ttl": 3600,
                            "type": "MX",
                        },
                        {
                            "name": mainDomain + ".",
                            "rrdatas": ['"v=spf1 include:_spf.google.com ~all"'],
                            "ttl": 3600,
                            "type": "SPF",
                        },
                        {
                            "name": mainDomain + ".",
                            "rrdatas": ['"v=spf1 include:_spf.google.com ~all"'],
                            "ttl": 3600,
                            "type": "TXT",
                        },
                        {
                            "name": "google._domainkey.sudonym.app.",
                            "rrdatas": [
                                '"v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5fSri/lTTkAQi31waZIucur+3n6ldkOVkqpzIWqIha9cdNICtX2u+fzbqUuSMdWluUtYZ10G4tuo00FFdekSQQbOBTjLYFY3GPgtiktzO+96OJMu7OBf3FwIHoufR0AU3txd3ALrr2l6TBjyR2uvviG+S1QXn39XDDgeiLzGzRMij2GLDO2MRzDxdA5DT2alC" "qIrzC2SI3HWaN5Y3JNyYTE68QhFviGITm+5z1Mhj4lO5Su+mGcGhjjjEAzxcel7jE4hXc1Bget2Km223WKD+ahc7hRe/bsDMfL2S1sTVQFv+PICirZf/jEtyyRjgJa72vaRMmD23lZLC1nvR/bJwQIDAQAB"'
                            ],
                            "ttl": 3600,
                            "type": "TXT",
                        },
                    ],
                },
            },
        ]
    )

    return {"resources": resources}