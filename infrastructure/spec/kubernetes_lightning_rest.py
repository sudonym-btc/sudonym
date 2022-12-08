from helper import (addNum, getConfigName, getDeploymentName, getServiceName,
                    getVolumeClaimName)
from kubernetes_cluster import cluster
from kubernetes_lightning import lightning


def lightning_rest(config, cluster_types):
    kube_type_name = cluster(config)["kube_type_name"]
    lightning_base_name = lightning(config, cluster_types)["base_name"]
    base_name = config["env"] + "-c-lightning-rest"

    def getResource(num=1):

        return [
                {
                    "name": getVolumeClaimName(base_name + "-macaroon", num),
                    "type": cluster_types["PersistentVolumeClaim"],
                    "metadata": {"dependsOn": [kube_type_name]},
                    "properties": {
                        "apiVersion": "v1",
                        "kind": "PersistentVolumeClaim",
                        "namespace": "default",
                        "metadata": {"name": getVolumeClaimName(base_name + "-macaroon", num)},
                        "spec": {
                            "accessModes": ["ReadWriteOnce"],
                            "resources": {"requests": {"storage": "1Gi"}},
                        },
                    },
                },
                {
                    "name": getConfigName(base_name, num),
                    "type": cluster_types["ConfigMap"],
                    "metadata": {"dependsOn": [kube_type_name]},
                    "properties": {
                        "apiVersion": "v1",
                        "kind": "ConfigMap",
                        "metadata": {"name": "cl-rest-config.json", "namespace": "default"},
                        "namespace": "default",
                        "data": {
                            "cl-rest-config.json": """
    {
        "PORT": """
                            + str(config["lightningRest"]["port"])
                            + """,
        "DOCPORT": """
                            + str(config["lightningRest"]["docPort"])
                            + """,
        "PROTOCOL": "http",
        "EXECMODE": """ 
                            + ("\"production\"" if config["env"] == "production" else "\"test\"")
                            + """,
        "LNRPCPATH": "/rpc/lightning-rpc",
        "RPCCOMMANDS": ["*"]
    }
    """
                        },
                    },
                },
                {
                    "name": getServiceName(base_name, num),
                    "type": cluster_types["Service"],
                    "metadata": {"dependsOn": [kube_type_name]},
                    "properties": {
                        "apiVersion": "v1",
                        "kind": "Service",
                        "namespace": "default",
                        "metadata": {
                            "name": getServiceName(base_name, num),
                            "labels": {"app": addNum(base_name, num)},
                        },
                        "spec": {
                            "type": "NodePort",
                            "ports": [
                                {
                                    "port": config["lightningRest"]["port"],
                                    "name": "ln-rest",
                                },
                            ],
                            "selector": {"app": addNum(base_name, num)},
                        },
                    },
                },
                {
                    "name": getServiceName(base_name + "-doc", num),
                    "type": cluster_types["Service"],
                    "metadata": {"dependsOn": [kube_type_name]},
                    "properties": {
                        "apiVersion": "v1",
                        "kind": "Service",
                        "namespace": "default",
                        "metadata": {
                            "name": getServiceName(base_name + "-doc", num),
                            "labels": {"app": addNum(base_name, num)},
                        },
                        "spec": {
                            "type": "NodePort",
                            "ports": [
                                {
                                    "port": config["lightningRest"]["docPort"],
                                    "name": "ln-rest-doc",
                                },
                            ],
                            "selector": {"app": addNum(base_name, num)},
                        },
                    },
                },
                {
                    "name": getDeploymentName(base_name, num),
                    "type": cluster_types["Deployment"],
                    "metadata": {
                        "dependsOn": [
                            kube_type_name,
                            getVolumeClaimName(lightning_base_name + "-rpc", num),
                        ]
                    },
                    "properties": {
                        "apiVersion": "apps/v1",
                        "kind": "Deployment",
                        "namespace": "default",
                        "metadata": {
                            "name": getDeploymentName(base_name, num),
                            "labels": {"app": addNum(base_name, num)},
                        },
                        "spec": {
                            "strategy": {"type": "Recreate"},
                            "replicas": 1,
                            "selector": {"matchLabels": {"app": addNum(base_name, num)}},
                            "template": {
                                "metadata": {
                                    "labels": {"app": addNum(base_name, num)},
                                },
                                "spec": {
                                    "containers": [
                                        {
                                            "name": addNum(base_name, num),
                                            "image": "saubyk/c-lightning-rest:0.9.0",
                                            "command": [
                                                "/sbin/tini",
                                                "--",
                                                "node",
                                                "./cl-rest.js",
                                            ],
                                            "ports": [
                                                {
                                                    "containerPort": config[
                                                        "lightningRest"
                                                    ]["port"]
                                                },
                                                {"containerPort": 4001},
                                            ],
                                            "volumeMounts": [
                                                {
                                                    "mountPath": "/usr/src/app/cl-rest-config.json",
                                                    "subPath": "cl-rest-config.json",
                                                    "name": "json-config",
                                                },
                                                {
                                                    "name": getVolumeClaimName(
                                                        lightning_base_name + "-rpc", num
                                                    ),
                                                    "mountPath": "/rpc",
                                                },
                                                {
                                                    "name": getVolumeClaimName(
                                                        base_name + "-macaroon", num
                                                    ),
                                                    "mountPath": "/usr/src/app/certs",
                                                },
                                            ],

                                            "resources": {
                                                "limits": {
                                                    "cpu": "0.01",
                                                    "memory": "50Mi"
                                                },
                                                "requests": {
                                                    "cpu": "0.005",
                                                    "memory": "50Mi"
                                                }
                                            }
                                        }
                                    ],
                                    "volumes": [
                                        {
                                            "name": "json-config",
                                            "configMap": {"name": "cl-rest-config.json"},
                                        },
                                        {
                                            "name": getVolumeClaimName(
                                                lightning_base_name + "-rpc", num
                                            ),
                                            "persistentVolumeClaim": {
                                                "claimName": getVolumeClaimName(
                                                    lightning_base_name + "-rpc", num
                                                )
                                            },
                                        },
                                        {
                                            "name": getVolumeClaimName(
                                                base_name + "-macaroon", num
                                            ),
                                            "persistentVolumeClaim": {
                                                "claimName": getVolumeClaimName(
                                                    base_name + "-macaroon", num
                                                )
                                            },
                                        },
                                    ],
                                },
                            },
                        },
                    },
                },
            ]
            
    return  {
        "resources": getResource(1) + (getResource(2) + getResource(3) if config["env"] == "development" else []),
        "base_name": base_name,
        }
