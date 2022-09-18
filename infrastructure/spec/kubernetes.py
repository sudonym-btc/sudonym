#
# This is modified version of code provided by Google at:
# https://github.com/GoogleCloudPlatform/deploymentmanager-samples
#

from common import getConfig
from dns import dns
from helper import getServiceName
from kubernetes_ride_the_lightning import ride_the_lightning
from kubernetes_lightning_rest import lightning_rest
from kubernetes_cluster import cluster
from kubernetes_bitcoin import bitcoin
from kubernetes_lightning import lightning
from kubernetes_lightning_rest import lightning_rest
from kubernetes_api import api


def GenerateConfig(context):

    config = getConfig(context.properties["env"])
    kube_type_name = cluster(config)["kube_type_name"]

    cluster_types_root = "".join([config["project"], "/", kube_type_name])
    cluster_types = {
        "Service": "".join(
            [cluster_types_root, ":", "/api/v1/namespaces/{namespace}/services/{name}"]
        ),
        "ConfigMap": "".join(
            [
                cluster_types_root,
                ":",
                "/api/v1/namespaces/{namespace}/configmaps/{name}",
            ]
        ),
        "Deployment": "".join(
            [
                cluster_types_root,
                ":",
                "/apis/apps/v1/namespaces/{namespace}/deployments/{name}",
            ]
        ),
        "PersistentVolumeClaim": "".join(
            [
                cluster_types_root,
                ":",
                "/api/v1/namespaces/{namespace}/persistentvolumeclaims/{name}",
            ]
        ),
        "Secret": "".join(
            [
                cluster_types_root,
                ":",
                "/api/v1/namespaces/{namespace}/secrets/{name}",
            ]
        ),
        "Ingress": "".join(
            [
                cluster_types_root,
                ":",
                "/apis/networking.k8s.io/v1/namespaces/{namespace}/ingresses/{name}",
            ]
        ),
    }

    ride_the_lightning_base_name = ride_the_lightning(config, cluster_types)[
        "base_name"
    ]
    lightning_rest_base_name = lightning_rest(config, cluster_types)["base_name"]
    api_base_name = api(config, cluster_types)["base_name"]
    bitcoin_base_name = bitcoin(config, cluster_types)["base_name"]

    resources = (
        [
            {
                "name": config["env"] + "-ingress",
                "type": cluster_types["Ingress"],
                "metadata": {"dependsOn": [kube_type_name, config["env"] + "-ip"]},
                "properties": {
                    "apiVersion": "networking.k8s.io/v1",
                    "kind": "Ingress",
                    "namespace": "default",
                    "metadata": {
                        "name": config["env"] + "-ingress",
                        "annotations": {
                            # "kubernetes.io/ingress.class": "nginx",
                            #                             "nginx.org/websocket-services": api_base_name + "-service",
                            #                             "nginx.ingress.kubernetes.io/proxy-read-timeout": "3600",
                            #                             "nginx.ingress.kubernetes.io/proxy-send-timeout": "3600",
                            #                             "nginx.ingress.kubernetes.io/configuration-snippet": """
                            #    proxy_http_version 1.1;
                            #    proxy_set_header Upgrade "websocket";
                            #    proxy_set_header Connection "Upgrade";""",
                            "kubernetes.io/ingress.global-static-ip-name": config["env"]
                            + "-ip"
                        },
                    },
                    "spec": {
                        "defaultBackend": {
                            "service": {
                                "name": getServiceName(ride_the_lightning_base_name),
                                "port": {"number": config["rtl"]["port"]},
                            }
                        },
                        "tls": [
                            {
                                "hosts": [
                                    "api." + config["domain"],
                                    "rtl." + config["domain"],
                                    "lightning-rest." + config["domain"],
                                    # "bitcoin-mq." + config["domain"],
                                ],
                                "secretName": "self-signed-tls",
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
                                                    "name": getServiceName(ride_the_lightning_base_name),
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
                                                    "name":getServiceName(bitcoin_base_name + "-zeromq"),
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
                        ],
                    },
                },
            },
        ]
        + cluster(config)["resources"]
        + bitcoin(config, cluster_types)["resources"]
        + lightning(config, cluster_types)["resources"]
        + lightning_rest(config, cluster_types)["resources"]
        + ride_the_lightning(config, cluster_types)["resources"]
        + api(config, cluster_types)["resources"]
        + dns(config, cluster_types)["resources"]
    )
    print(resources)
    return {"resources": resources, "cluster_types_root": cluster_types_root}
