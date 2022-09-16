from helper import (
    getBackupName,
    getDeploymentName,
    getSecretName,
    getServiceName,
    getVolumeClaimName,
)
from kubernetes_cluster import cluster
from kubernetes_bitcoin import bitcoin


def lightning(config, cluster_types):
    kube_type_name = cluster(config)["kube_type_name"]
    bitcoin_base_name = bitcoin(config, cluster_types)["base_name"]
    base_name = config["env"] + "-lightning"

    def getResource(num=1):
        return [
            {
                "type": "storage.v1.bucket",
                "name": "sudonym-" + getBackupName(base_name, num),
                "properties": {
                    "project": config["project"],
                },
            },
            {
                "name": getVolumeClaimName(base_name + "-rpc", num),
                "type": cluster_types["PersistentVolumeClaim"],
                "metadata": {"dependsOn": [kube_type_name]},
                "properties": {
                    "apiVersion": "v1",
                    "kind": "PersistentVolumeClaim",
                    "namespace": "default",
                    "metadata": {"name": getVolumeClaimName(base_name + "-rpc", num)},
                    "spec": {
                        "accessModes": ["ReadWriteOnce"],
                        "resources": {"requests": {"storage": "10Gi"}},
                    },
                },
            },
            {
                "name": getVolumeClaimName(base_name + "-backup", num),
                "type": cluster_types["PersistentVolumeClaim"],
                "metadata": {"dependsOn": [kube_type_name]},
                "properties": {
                    "apiVersion": "v1",
                    "kind": "PersistentVolumeClaim",
                    "namespace": "default",
                    "metadata": {
                        "name": getVolumeClaimName(base_name + "-backup", num)
                    },
                    "spec": {
                        "accessModes": ["ReadWriteOnce"],
                        "resources": {"requests": {"storage": "10Gi"}},
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
                        "labels": {"app": base_name},
                    },
                    "spec": {
                        "type": "NodePort",
                        "ports": [
                            {"port": config["lightning"]["port"], "name": base_name},
                        ],
                        "selector": {"app": base_name},
                    },
                },
            },
            {
                "name": getDeploymentName(base_name, num),
                "type": cluster_types["Deployment"],
                "metadata": {
                    "dependsOn": [
                        kube_type_name,
                        getVolumeClaimName(base_name + "-rpc", num),
                        getVolumeClaimName(base_name + "-backup", num),
                    ],
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
                                "containers": [
                                    {
                                        "securityContext": {
                                            "privileged": True,
                                            "capabilities": {"add": ["SYS_ADMIN"]},
                                        },
                                        "lifecycle": {
                                            "postStart": {
                                                "exec": {
                                                    "command": [
                                                        "sh",
                                                        "-c",
                                                        "mkdir -p /lightning/"
                                                        + config["network"]
                                                        + " >/dev/null 2>&1 && echo $(gcsfuse --log-file /home/log.txt --debug_gcs --debug_fuse --debug_http --debug_fs sudonym-development-lightning-backup /lightning/"
                                                        + config["network"]
                                                        + ")",
                                                    ]  # --log-file /home/log.txt --debug_gcs --debug_fuse --debug_http --debug_fs
                                                }
                                            },
                                            "preStop": {
                                                "exec": {
                                                    "command": [
                                                        "fusermount",
                                                        "-u",
                                                        "/home/backup",
                                                    ],
                                                }
                                            },
                                        },
                                        "name": base_name,
                                        "image": "gcr.io/"
                                        + config["project"]
                                        + "/fuse-lightning",
                                        "resources": {"requests": {"cpu": "40m"}},
                                        "command": [
                                            "/bin/sh",
                                            "-ec",
                                            "sleep 20; ./entrypoint.sh "
                                            + " ".join(
                                                [
                                                    "--bitcoin-rpcuser=$(BITCOIN_RPC_USER)",
                                                    "--bitcoin-rpcpassword=$(BITCOIN_RPC_PASSWORD)",
                                                    "--bitcoin-rpcconnect="
                                                    + getServiceName(bitcoin_base_name),
                                                    "--log-level=debug",
                                                    "--lightning-dir=/lightning",
                                                    "--rpc-file=/rpc/lightning-rpc",
                                                    "--addr=0.0.0.0:"
                                                    + str(config["lightning"]["port"]),
                                                    "--experimental-offers",
                                                    "--network=" + config["network"],
                                                    # "--wallet=sqlite3:///lightning/"
                                                    # + config["network"]
                                                    # + "/lightningd.sqlite3",
                                                    "--bitcoin-rpcport="
                                                    + str(config["bitcoin"]["rpcPort"]),
                                                ]
                                            ),
                                        ],
                                        "env": [
                                            {"name": "EXPOSE_TCP", "value": "true"},
                                            {
                                                "name": "BITCOIN_RPC_USER",
                                                "valueFrom": {
                                                    "secretKeyRef": {
                                                        "name": getSecretName(
                                                            bitcoin_base_name
                                                        ),
                                                        "key": "rpcuser",
                                                    }
                                                },
                                            },
                                            {
                                                "name": "BITCOIN_RPC_PASSWORD",
                                                "valueFrom": {
                                                    "secretKeyRef": {
                                                        "name": getSecretName(
                                                            bitcoin_base_name
                                                        ),
                                                        "key": "rpcpass",
                                                    }
                                                },
                                            },
                                        ],
                                        "ports": [
                                            {
                                                "containerPort": config["lightning"][
                                                    "port"
                                                ],
                                                "name": "ln",
                                            },
                                        ],
                                        "volumeMounts": [
                                            {
                                                "name": getVolumeClaimName(
                                                    base_name + "-rpc", num
                                                ),
                                                "mountPath": "/rpc",
                                            },
                                            {
                                                "name": getVolumeClaimName(
                                                    base_name + "-backup", num
                                                ),
                                                "mountPath": "/lightning",
                                            },
                                        ],
                                    }
                                ],
                                "volumes": [
                                    {
                                        "name": getVolumeClaimName(
                                            base_name + "-rpc", num
                                        ),
                                        "persistentVolumeClaim": {
                                            "claimName": getVolumeClaimName(
                                                base_name + "-rpc", num
                                            )
                                        },
                                    },
                                    {
                                        "name": getVolumeClaimName(
                                            base_name + "-backup", num
                                        ),
                                        "persistentVolumeClaim": {
                                            "claimName": getVolumeClaimName(
                                                base_name + "-backup", num
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

    return {
        "resources": [] + getResource(1) + getResource(2) + getResource(3),
        "base_name": base_name,
    }
