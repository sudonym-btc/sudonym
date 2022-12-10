from helper import (getBackupName, getConfigName, getDeploymentName,
                    getSecretName, getServiceName, getVolumeClaimName)
from kubernetes_cluster import cluster


def getBitcoinChainName(name) :
    if(name == "mainnet") : return "main"
    if(name == "testnet") : return "test"
    return name


def bitcoin(config, cluster_types):

    kube_type_name = cluster(config)["kube_type_name"]
    base_name = config["env"] + "-bitcoin"

    data_dir = "/home/bitcoin/.bitcoin"

    return {
        "resources": [
            {
                "type": "storage.v1.bucket",
                "name": "sudonym-" + getBackupName(base_name),
                "properties": {
                    "project": config["project"],
                    "location": "US-CENTRAL1",
                    "locationType": "region",
                    "iamConfiguration": {
                        "publicAccessPrevention": "enforced",
                        "uniformBucketLevelAccess": {
                            "enabled": True
                        },
                    },
                },
            },
            {
                "name": getSecretName(base_name),
                "type": cluster_types["Secret"],
                "metadata": {"dependsOn": [kube_type_name]},
                "properties": {
                    "apiVersion": "v1",
                    "kind": "Secret",
                    "namespace": "default",
                    "metadata": {"name": base_name + "-secret"},
                    "type": "Opaque",
                    "data": {"rpcuser": "dGVzdA==", "rpcpass": "dGVzdA=="},
                },
            },
            {
                "name": getVolumeClaimName(base_name),
                "type": cluster_types["PersistentVolumeClaim"],
                "metadata": {"dependsOn": [kube_type_name]},
                "properties": {
                    "apiVersion": "v1",
                    "kind": "PersistentVolumeClaim",
                    "namespace": "default",
                    "metadata": {"name": getVolumeClaimName(base_name)},
                    "spec": {
                        "accessModes": ["ReadWriteOnce"],
                        "resources": {"requests": {"storage": "20Gi" if config["env"] == "development" else "700Gi" }},
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
                            {"port": config["bitcoin"]["rpcPort"], "name": "rpc"},
                            {"port": config["bitcoin"]["port"], "name": base_name},
                        ],
                        "selector": {"app": base_name},
                    },
                },
            },
            {
                "name": getServiceName(base_name + "-zeromq"),
                "type": cluster_types["Service"],
                "metadata": {"dependsOn": [kube_type_name]},
                "properties": {
                    "apiVersion": "v1",
                    "kind": "Service",
                    "namespace": "default",
                    "metadata": {
                        "name": getServiceName(base_name + "-zeromq"),
                        "labels": {"app": base_name},
                    },
                    "spec": {
                        "type": "NodePort",
                        "ports": [
                            {"port": 5555, "name": "zeromq", "protocol": "TCP"},
                        ],
                        "selector": {"app": base_name},
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
                    "namespace": "default",
                    "metadata": {
                        "name": 'settings.json',
                        "labels": {"app": base_name},
                    },
                    "data": {
                        "settings.json": "{}",
                    },
                },
            },
            {
                "name": getDeploymentName(base_name),
                "type": cluster_types["Deployment"],
                "metadata": {
                    "dependsOn": [
                        kube_type_name,
                        getVolumeClaimName(base_name),
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
                            "metadata": {"labels": {"app": base_name}},
                            "spec": {
                                "terminationGracePeriodSeconds": 60,
                                "containers": [
                                    {
                                        "securityContext": {
                                            "privileged": True,
                                            "capabilities": {"add": ["SYS_ADMIN"]},
                                        },
                                        "name": base_name,
                                        "image": "gcr.io/"
                                        + config["project"]
                                        + "/fuse-bitcoin",
                                        "command": [
                                            "sh",
                                            "-c",
                                            (
                                                "" # backup gsutil copy
                                                if config["backup"]
                                                else ""
                                            ) +
                                        "bitcoind "
                                            + " ".join(
                                                [
                                                    "-server",
                                                    "-nosettings",
                                                    "-rest",
                                                    "-txindex",
                                                    "-datadir=" + data_dir,
                                                    "-chain=" + getBitcoinChainName(config["network"]),
                                                    "-port="
                                                    + str(config["bitcoin"]["port"]),
                                                    "-rpcuser=$(BITCOIN_RPC_USER)",
                                                    "-rpcpassword=$(BITCOIN_RPC_PASSWORD)",
                                                    "-rpcallowip=0.0.0.0/0",
                                                    "-rpcallowip=::/0",
                                                    "-rpcport="
                                                    + str(config["bitcoin"]["rpcPort"]),
                                                    "-rpcbind=0.0.0.0",
                                                    "-rpcbind=" + base_name,
                                                    "-zmqpubrawtx=tcp://*:5555",
                                                    "-zmqpubhashblock=tcp://*:5555",
                                                    "-zmqpubhashtx=tcp://*:5555",
                                                    "-zmqpubrawblock=tcp://*:5555",
                                                    "-debug=" + ("1" if config["loglevel"] == "debug" else "0"),
                                                ]
                                            ),
                                        ],
                                        "env": [
                                            {
                                                "name": "POD_ID",
                                                "valueFrom": {
                                                    "fieldRef": {
                                                        "fieldPath": "metadata.name"
                                                    }
                                                }
                                            },
                                            {
                                                "name": "BITCOIN_RPC_USER",
                                                "valueFrom": {
                                                    "secretKeyRef": {
                                                        "name": base_name + "-secret",
                                                        "key": "rpcuser",
                                                    }
                                                },
                                            },
                                            {
                                                "name": "BITCOIN_RPC_PASSWORD",
                                                "valueFrom": {
                                                    "secretKeyRef": {
                                                        "name": base_name + "-secret",
                                                        "key": "rpcpass",
                                                    }
                                                },
                                            },
                                        ],
                                        "ports": [
                                            {
                                                "containerPort": config["bitcoin"][
                                                    "rpcPort"
                                                ],
                                                "name": "rpc",
                                            },
                                            {
                                                "containerPort": config["bitcoin"][
                                                    "port"
                                                ],
                                                "name": "bitcoin",
                                            },
                                            {
                                                "containerPort": 5555,
                                                "name": "zeromq",
                                            },
                                        ],
                                        "volumeMounts": [
                                            {
                                                "name": getVolumeClaimName(base_name),
                                                "mountPath": data_dir,
                                            },
                                        ],
                                        "resources": {
                                            "limits": {
                                                "cpu": "0.5",
                                                "memory": "4Gi"
                                            },
                                            "requests": {
                                                "cpu": "0.01",
                                                "memory": "2Gi"
                                            }
                                        }
                                    }
                                ],
                                "volumes": [
                                    {
                                        "name": getVolumeClaimName(base_name),
                                        "persistentVolumeClaim": {
                                            "claimName": getVolumeClaimName(base_name)
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
