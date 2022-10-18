import sys
from dns import dns
from common import getConfig

def certificates(config):

    domain = dns(config, False)["domain"]

    resources = [
        {
            "apiVersion": "cert-manager.io/v1",
            "kind": "Issuer",
            "metadata": {
                "name": "dns-issuer"
            },
            "spec": {
                "acme": {
                    "email": "patrick.geyer1@gmail.com",
                    "server": "https://acme-v02.api.letsencrypt.org/directory",
                    "privateKeySecretRef": {
                        "name": "letsencrypt-prod-account-key"
                    },
                    "solvers": [{
                        "dns01": {
                            "cnameStrategy": "Follow",
                            "cloudDNS": {
                                # The ID of the GCP project
                                "project": config["project"],
                                # This is the secret used to access the service account
                                "serviceAccountSecretRef": {
                                    "name": config["env"] + "-cert-resolver",
                                    "key": "key.json"
                                }
                            }
                        }
                }]
                    }
                }
            }, {
            "apiVersion": "cert-manager.io/v1",
            "kind": "Certificate",
            "metadata": {
                "name": config["env"] + "-tls",
            },
            "spec": {
                "secretName": config["env"] + "-tls",
                "privateKey": {
                    "rotationPolicy": "Always"
                },
                "dnsNames":[
                    "" + domain,
                    "www." + domain,
                    "rtl." + domain,
                    "api." + domain,
                    "btc." + domain,
                    "ln." + domain,
                    "ln-doc." + domain,
                    "ln-rest." + domain,
                    "db." + domain,
                    "bitcoin-mq." + domain,
                ],
                "issuerRef": {
                    "name": "dns-issuer"
                }
            }
        }]

    return {"resources": resources}



config = getConfig(sys.argv[1] if len(sys.argv) > 1 else "development")
from yaml import dump_all, dump

print(dump_all(certificates(config)["resources"]))