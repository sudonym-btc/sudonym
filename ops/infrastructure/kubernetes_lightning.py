from kubernetes_cluster import cluster
from kubernetes_bitcoin import bitcoin

def lightning(config, cluster_types):
    kube_type_name = cluster(config)["kube_type_name"]
    bitcoin_base_name = bitcoin(config, cluster_types)["base_name"]
    base_name = config["env"] + "-lightning"

    return {
        "resources": [
            {
                "name": base_name + "-volume-claim",
                "type": cluster_types["PersistentVolumeClaim"],
                "metadata": {"dependsOn": [kube_type_name]},
                "properties": {
                    "apiVersion": "v1",
                    "kind": "PersistentVolumeClaim",
                    "namespace": "default",
                    "metadata": {"name": base_name + "-volume-claim"},
                    "spec": {
                        "accessModes": ["ReadWriteOnce"],
                        "resources": {"requests": {"storage": "10Gi"}},
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
                            {"port": 9735, "name": base_name},
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
                        base_name + "-volume-claim",
                    ]
                },
                "properties": {
                    "apiVersion": "apps/v1",
                    "kind": "Deployment",
                    "namespace": "default",
                    "metadata": {"name": base_name, "labels": {"app": base_name}},
                    "spec": {
                        "strategy": {"type": "Recreate"},
                        "replicas": 1,
                        "selector": {"matchLabels": {"app": base_name}},
                        "template": {
                            "metadata": {"labels": {"app": base_name}},
                            "spec": {
                                "containers": [
                                    {
                                        "name": base_name,
                                        "image": "elementsproject/lightningd:latest",
                                        "resources": {"requests": {"cpu": "40m"}},
                                        "args": [
                                            "--bitcoin-rpcuser=$(BITCOIN_RPC_USER)",
                                            "--bitcoin-rpcpassword=$(BITCOIN_RPC_PASSWORD)",
                                            "--bitcoin-rpcconnect=" + bitcoin_base_name,
                                            "--bitcoin-rpcport=18443",
                                            "--network=regtest",
                                            "--log-level=debug",
                                            "--rpc-file=/rpc/lightning-rpc",
                                        ],
                                        "env": [
                                            {
                                                "name": "BITCOIN_RPC_USER",
                                                "valueFrom": {
                                                    "secretKeyRef": {
                                                        "name": bitcoin_base_name + "-secret",
                                                        "key": "rpcuser",
                                                    }
                                                },
                                            },
                                            {
                                                "name": "BITCOIN_RPC_PASSWORD",
                                                "valueFrom": {
                                                    "secretKeyRef": {
                                                        "name": bitcoin_base_name + "-secret",
                                                        "key": "rpcpass",
                                                    }
                                                },
                                            },
                                        ],
                                        "ports": [
                                            {"containerPort": 9735, "name": "ln"},
                                        ],
                                        "volumeMounts": [
                                            {
                                                "name": base_name + "-data",
                                                "mountPath": "/rpc",
                                            }
                                        ],
                                    }
                                ],
                                "volumes": [
                                    {
                                        "name": base_name + "-data",
                                        "persistentVolumeClaim": {
                                            "claimName": base_name + "-volume-claim"
                                        },
                                    }
                                ],
                            },
                        },
                    },
                },
            },
        ],
        "base_name": base_name,
    }
