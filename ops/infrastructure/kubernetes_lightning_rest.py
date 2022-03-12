from kubernetes_cluster import cluster
from kubernetes_lightning import lightning

def lightning_rest(config, cluster_types):
    kube_type_name = cluster(config)["kube_type_name"]
    lightning_base_name = lightning(config, cluster_types)["base_name"]
    base_name = config["env"] + "-c-lightning-rest"

    return {
        "resources": [
            {
                "name": "macaroon-volume-claim",
                "type": cluster_types["PersistentVolumeClaim"],
                "metadata": {"dependsOn": [kube_type_name]},
                "properties": {
                    "apiVersion": "v1",
                    "kind": "PersistentVolumeClaim",
                    "namespace": "default",
                    "metadata": {"name": "macaroon-volume-claim"},
                    "spec": {
                        "accessModes": ["ReadWriteOnce"],
                        "resources": {"requests": {"storage": "1Gi"}},
                    },
                },
            },
            {
                "name": base_name + "-config",
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
    "PORT": 3001,
    "DOCPORT": 4001,
    "PROTOCOL": "https",
    "EXECMODE": "test",
    "LNRPCPATH": "/rpc/lightning-rpc",
    "RPCCOMMANDS": ["*"]
}
"""
                    },
                },
            },
            {
                "name": base_name + "-service",
                "type": cluster_types["Service"],
                "metadata": {"dependsOn": [kube_type_name]},
                "properties": {
                    "apiVersion": "v1",
                    "kind": "Service",
                    "namespace": "default",
                    "metadata": {
                        "name": base_name + "-service",
                        "labels": {"app": base_name},
                    },
                    "spec": {
                        "type": "NodePort",
                        "ports": [
                            {"port": 3001, "name": "ln-rest"},
                            {"port": 4001, "name": "ln-rest-doc"},
                        ],
                        "selector": {"app": base_name},
                    },
                },
            },
            {
                "name": base_name,
                "type": cluster_types["Deployment"],
                "metadata": {
                    "dependsOn": [
                        kube_type_name,
                        lightning_base_name + "-volume-claim",
                    ]
                },
                "properties": {
                    "apiVersion": "apps/v1",
                    "kind": "Deployment",
                    "namespace": "default",
                    "metadata": {
                        "name": base_name + "-deployment",
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
                                        "image": "saubyk/c-lightning-rest:0.6.1",
                                        "command": [
                                            "/sbin/tini",
                                            "--",
                                            "node",
                                            "./cl-rest.js",
                                        ],
                                        "resources": {"requests": {"cpu": "40m"}},
                                        "ports": [{"containerPort": 3001}],
                                        "volumeMounts": [
                                            {
                                                "mountPath": "/usr/src/app/cl-rest-config.json",
                                                "subPath": "cl-rest-config.json",
                                                "name": "json-config",
                                            },
                                            {
                                                "name": lightning_base_name + "-data",
                                                "mountPath": "/rpc",
                                            },
                                            {
                                                "name": "macaroon-data",
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
                                        "name": lightning_base_name + "-data",
                                        "persistentVolumeClaim": {
                                            "claimName": lightning_base_name
                                            + "-volume-claim"
                                        },
                                    },
                                    {
                                        "name": "macaroon-data",
                                        "persistentVolumeClaim": {
                                            "claimName": "macaroon-volume-claim"
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
