from helper import getConfigName, getDeploymentName, getServiceName, getVolumeClaimName
from kubernetes_cluster import cluster
from kubernetes_lightning import lightning


def lightning_rest(config, cluster_types):
    kube_type_name = cluster(config)["kube_type_name"]
    lightning_base_name = lightning(config, cluster_types)["base_name"]
    base_name = config["env"] + "-c-lightning-rest"

    return {
        "resources": [
            {
                "name": getVolumeClaimName(base_name + "-macaroon"),
                "type": cluster_types["PersistentVolumeClaim"],
                "metadata": {"dependsOn": [kube_type_name]},
                "properties": {
                    "apiVersion": "v1",
                    "kind": "PersistentVolumeClaim",
                    "namespace": "default",
                    "metadata": {"name": getVolumeClaimName(base_name + "-macaroon")},
                    "spec": {
                        "accessModes": ["ReadWriteOnce"],
                        "resources": {"requests": {"storage": "1Gi"}},
                    },
                },
            },
            {
                "name": getConfigName(base_name),
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
    "EXECMODE": "test",
    "LNRPCPATH": "/rpc/lightning-rpc",
    "RPCCOMMANDS": ["*"]
}
"""
                    },
                },
            },
            {
                "name": getServiceName(base_name),
                "type": cluster_types["Service"],
                "metadata": {"dependsOn": [kube_type_name]},
                "properties": {
                    "apiVersion": "v1",
                    "kind": "Service",
                    "namespace": "default",
                    "metadata": {
                        "name": getServiceName(base_name),
                        "labels": {"app": base_name},
                    },
                    "spec": {
                        "type": "NodePort",
                        "ports": [
                            {
                                "port": config["lightningRest"]["port"],
                                "name": "ln-rest",
                            },
                        ],
                        "selector": {"app": base_name},
                    },
                },
            },
            {
                "name": getServiceName(base_name + "-doc"),
                "type": cluster_types["Service"],
                "metadata": {"dependsOn": [kube_type_name]},
                "properties": {
                    "apiVersion": "v1",
                    "kind": "Service",
                    "namespace": "default",
                    "metadata": {
                        "name": getServiceName(base_name + "-doc"),
                        "labels": {"app": base_name},
                    },
                    "spec": {
                        "type": "NodePort",
                        "ports": [
                            {
                                "port": config["lightningRest"]["docPort"],
                                "name": "ln-rest-doc",
                            },
                        ],
                        "selector": {"app": base_name},
                    },
                },
            },
            {
                "name": getDeploymentName(base_name),
                "type": cluster_types["Deployment"],
                "metadata": {
                    "dependsOn": [
                        kube_type_name,
                        getVolumeClaimName(lightning_base_name + "-rpc"),
                    ]
                },
                "properties": {
                    "apiVersion": "apps/v1",
                    "kind": "Deployment",
                    "namespace": "default",
                    "metadata": {
                        "name": getDeploymentName(base_name),
                        "labels": {"app": base_name},
                    },
                    "spec": {
                        "strategy": {"type": "Recreate"},
                        "replicas": 1,
                        "selector": {"matchLabels": {"app": base_name}},
                        "template": {
                            "metadata": {
                                "labels": {"app": base_name},
                            },
                            "spec": {
                                "containers": [
                                    {
                                        "name": base_name,
                                        "image": "saubyk/c-lightning-rest:0.9.0",
                                        "command": [
                                            "/sbin/tini",
                                            "--",
                                            "node",
                                            "./cl-rest.js",
                                        ],
                                        "resources": {"requests": {"cpu": "30m"}},
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
                                                    lightning_base_name + "-rpc"
                                                ),
                                                "mountPath": "/rpc",
                                            },
                                            {
                                                "name": getVolumeClaimName(
                                                    base_name + "-macaroon"
                                                ),
                                                "mountPath": "/usr/src/app/certs",
                                            },
                                        ],
                                    }
                                ],
                                "volumes": [
                                    {
                                        "name": "json-config",
                                        "configMap": {"name": "cl-rest-config.json"},
                                    },
                                    {
                                        "name": getVolumeClaimName(
                                            lightning_base_name + "-rpc"
                                        ),
                                        "persistentVolumeClaim": {
                                            "claimName": getVolumeClaimName(
                                                lightning_base_name + "-rpc"
                                            )
                                        },
                                    },
                                    {
                                        "name": getVolumeClaimName(
                                            base_name + "-macaroon"
                                        ),
                                        "persistentVolumeClaim": {
                                            "claimName": getVolumeClaimName(
                                                base_name + "-macaroon"
                                            )
                                        },
                                    },
                                ],
                            },
                        },
                    },
                },
            },
        ],
        "base_name": base_name,
    }
