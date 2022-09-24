from helper import getDeploymentName, getServiceName, getVolumeClaimName
from kubernetes_cluster import cluster
from kubernetes_lightning_rest import lightning_rest

from kubernetes_db import db
from kubernetes_ride_the_lightning import ride_the_lightning
from kubernetes_lightning_rest import lightning_rest
from kubernetes_cluster import cluster
from kubernetes_bitcoin import bitcoin
from kubernetes_lightning_rest import lightning_rest
from kubernetes_api import api


def ingress(config, cluster_types):
    kube_type_name = cluster(config)["kube_type_name"]
    base_name = config["env"] + "-ingress"

    ride_the_lightning_base_name = ride_the_lightning(config, cluster_types)[
        "base_name"
    ]
    lightning_rest_base_name = lightning_rest(config, cluster_types)["base_name"]
    api_base_name = api(config, cluster_types)["base_name"]
    bitcoin_base_name = bitcoin(config, cluster_types)["base_name"]
    db_base_name = db(config, cluster_types)["base_name"]

    return {
        "resources": [
            {
                "name": config["env"] + "-ingress",
                "type": cluster_types["Ingress"],
                "metadata": {
                    "dependsOn": [
                        kube_type_name,
                        config["env"] + "-ip",
                    ]
                },
                "properties": {
                    "apiVersion": "networking.k8s.io/v1",
                    "kind": "Ingress",
                    "namespace": "default",
                    "metadata": {
                        "name": config["env"] + "-ingress",
                        "annotations": {
                            # "kubernetes.io/ingress.class": "nginx",
                            #                             "nginx.org/websocket-services": api_base_name + "-service",
                            "nginx.ingress.kubernetes.io/proxy-read-timeout": "3600",
                            "nginx.ingress.kubernetes.io/proxy-send-timeout": "3600",
                            #                             "nginx.ingress.kubernetes.io/configuration-snippet": """
                            #    proxy_http_version 1.1;
                            #    proxy_set_header Upgrade "websocket";
                            #    proxy_set_header Connection "Upgrade";""",
                            # "kubernetes.io/ingress.global-static-ip-name": config["env"]
                            # + "-ip",
                        },
                    },
                    "spec": {
                        "ingressClassName": "nginx",
                        "defaultBackend": {
                            "service": {
                                "name": getServiceName(api_base_name),
                                "port": {"number": config["api"]["websocketPort"]},
                            }
                        },
                        "tls": [
                            {
                                "hosts": [
                                    config["domain"],
                                    "api." + config["domain"],
                                    "rtl." + config["domain"],
                                    "lightning-rest." + config["domain"],
                                    # "bitcoin-mq." + config["domain"],
                                ],
                                "secretName": config["env"] + "-tls",
                            }
                        ],
                        "rules": [
                            {
                                "host": "rtl." + config["domain"],
                                "http": {
                                    "paths": [
                                        {
                                            "path": "/",
                                            "pathType": "Prefix",
                                            "backend": {
                                                "service": {
                                                    "name": getServiceName(
                                                        ride_the_lightning_base_name
                                                    ),
                                                    "port": {
                                                        "number": config["rtl"]["port"]
                                                    },
                                                }
                                            },
                                        }
                                    ]
                                },
                            },
                            {
                                "host": "bitcoin-mq." + config["domain"],
                                "http": {
                                    "paths": [
                                        {
                                            "path": "/",
                                            "pathType": "Prefix",
                                            "backend": {
                                                "service": {
                                                    "name": getServiceName(
                                                        bitcoin_base_name + "-zeromq"
                                                    ),
                                                    "port": {"number": 5555},
                                                }
                                            },
                                        }
                                    ]
                                },
                            },
                            {
                                "host": "lightning-rest." + config["domain"],
                                "http": {
                                    "paths": [
                                        {
                                            "path": "/",
                                            "pathType": "Prefix",
                                            "backend": {
                                                "service": {
                                                    "name": getServiceName(
                                                        lightning_rest_base_name
                                                    ),
                                                    "port": {
                                                        "number": config[
                                                            "lightningRest"
                                                        ]["port"]
                                                    },
                                                }
                                            },
                                        }
                                    ]
                                },
                            },
                            # Forward .well-known on base domain to API
                            {
                                "host": config["domain"],
                                "http": {
                                    "paths": [
                                        {
                                            "path": "/.well-known",
                                            "pathType": "Prefix",
                                            "backend": {
                                                "service": {
                                                    "name": getServiceName(
                                                        api_base_name
                                                    ),
                                                    "port": {
                                                        "number": config["api"]["port"]
                                                    },
                                                }
                                            },
                                        }
                                    ]
                                },
                            },
                            {
                                "host": "api." + config["domain"],
                                "http": {
                                    "paths": [
                                        {
                                            "path": "/",
                                            "pathType": "Prefix",
                                            "backend": {
                                                "service": {
                                                    "name": getServiceName(
                                                        api_base_name
                                                    ),
                                                    "port": {
                                                        "number": config["api"]["port"]
                                                    },
                                                }
                                            },
                                        },
                                        {
                                            "path": "/socket.io",
                                            "pathType": "Prefix",
                                            "backend": {
                                                "service": {
                                                    "name": getServiceName(
                                                        api_base_name
                                                    ),
                                                    "port": {
                                                        "number": config["api"][
                                                            "websocketPort"
                                                        ]
                                                    },
                                                }
                                            },
                                        },
                                    ]
                                },
                            },
                        ]
                        + (
                            [
                                {
                                    "host": "db." + config["domain"],
                                    "http": {
                                        "paths": [
                                            {
                                                "path": "/",
                                                "pathType": "Prefix",
                                                "backend": {
                                                    "service": {
                                                        "name": getServiceName(
                                                            db_base_name
                                                        ),
                                                        "port": {"number": 3306},
                                                    }
                                                },
                                            }
                                        ]
                                    },
                                },
                            ]
                            if config["env"] == "development"
                            else []
                        ),
                    },
                },
            },
        ],
        "base_name": base_name,
    }
