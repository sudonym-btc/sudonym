#
# This is modified version of code provided by Google at:
# https://github.com/GoogleCloudPlatform/deploymentmanager-samples
#
from common import getConfig
from dns import dns
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
    lightning_rest_base_name = lightning_rest(config, cluster_types)[
        "base_name"
    ]
    api_base_name = api(config, cluster_types)[
        "base_name"
    ]

    resources = (
        [
            {
                "name": config["env"] + "-ingress",
                "type": cluster_types["Ingress"],
                "metadata": {"dependsOn": [kube_type_name]},
                "properties": {
                    "apiVersion": "networking.k8s.io/v1",
                    "kind": "Ingress",
                    "namespace": "default",
                    "metadata": {
                        "name": config["env"] + "-ingress",
                        "annotations": {
                            "kubernetes.io/ingress.global-static-ip-name": config["env"]
                            + "-ip"
                        },
                    },
                    "spec": {
                        "defaultBackend": {
                            "service": {
                                "name": ride_the_lightning_base_name + "-service",
                                "port": {"number": 3000},
                            }
                        },
                        "rules": [
                            {
                                "host": "lightning-rest." + config["domain"],
                                "http": {
                                    "paths": [
                                        {
                                            "path": "/",
                                            "pathType": "Prefix",
                                            "backend": {
                                                "service": {
                                                    "name": lightning_rest_base_name + "-service",
                                                    "port": {"number": 3001},
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
                                                    "name": api_base_name + "-service",
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
                                                    "name": api_base_name + "-service",
                                                }
                                            },
                                        }
                                    ]
                                },
                            }
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

    return {"resources": resources, "cluster_types_root": cluster_types_root}
