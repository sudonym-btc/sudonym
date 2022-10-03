from helper import (
    addNum,
    getBackupName,
    getDeploymentName,
    getSecretName,
    getServiceName,
    getVolumeClaimName,
)
from kubernetes_cluster import cluster
from kubernetes_bitcoin import bitcoin

def getLightningChainName(name) :
    if(name == "mainnet") : return "bitcoin"
    return name


def lightning(config, cluster_types):
    kube_type_name = cluster(config)["kube_type_name"]
    bitcoin_base_name = bitcoin(config, cluster_types)["base_name"]
    base_name = config["env"] + "-lightning"

    chain_name = getLightningChainName(config["network"])

    def getResource(num=1):

        gcs_log = " --log-file /home/log.txt --debug_gcs --debug_fuse --debug_http --debug_fs " if config["loglevel"] == "debug" else ""
        lightning_dir = "root/.lightning"
        bucket = "sudonym-" + getBackupName(base_name, num)
        
        mount = f"""mkdir -p {lightning_dir}/{chain_name} && 
            echo $(gcsfuse --limit-ops-per-sec=0 {gcs_log} {bucket} {lightning_dir}/{chain_name})"""
        unmount = f"""fusermount -u {lightning_dir}/{chain_name}"""            

        return [
            {
                "type": "storage.v1.bucket",
                "name": "sudonym-" + getBackupName(base_name, num),
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
                        "labels": {"app": addNum(base_name, num)},
                    },
                    "spec": {
                        "type": "NodePort",
                        "ports": [
                            {"port": config["lightning"]["port"], "name": addNum(base_name, num)},
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
                        getVolumeClaimName(base_name + "-rpc", num),
                        getVolumeClaimName(base_name + "-backup", num),
                    ],
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
                            "metadata": {"labels": {"app": addNum(base_name, num)}},
                            "spec": {
                                "containers": [
                                    {
                                        "securityContext": {
                                            "privileged": True,
                                            "capabilities": {"add": ["SYS_ADMIN"]},
                                        },
                                        "lifecycle": {
                                            "preStop": {
                                                "exec": {
                                                    "command": [
                                                        unmount
                                                    ],
                                                }
                                            },
                                        }
                                        if config["backup"]
                                        else {},
                                        "name": addNum(base_name, num),
                                        "image": "gcr.io/"
                                        + config["project"]
                                        + "/fuse-lightning",
                                        "command": [
                                            "/bin/sh",
                                            "-ec",
                                            (
                                                f"{mount} &&"
                                                if config["backup"]
                                                else ""
                                            )
                                            + " ./entrypoint.sh "
                                            + " ".join(
                                                [
                                                    "--alias=" + config["appName"] + addNum(("-" + config["env"]) if config["env"] != "production" else "", num),
                                                    "--bitcoin-rpcuser=$(BITCOIN_RPC_USER)",
                                                    "--bitcoin-rpcpassword=$(BITCOIN_RPC_PASSWORD)",
                                                    "--bitcoin-rpcconnect="
                                                    + getServiceName(bitcoin_base_name),
                                                    "--log-level=" + config["loglevel"],
                                                    "--lightning-dir=" + lightning_dir,
                                                    "--rpc-file=/rpc/lightning-rpc",
                                                    "--addr=0.0.0.0:"
                                                    + str(config["lightning"]["port"]),
                                                    "--experimental-offers",
                                                    "--network=" + chain_name,
                                                    "--bitcoin-rpcport="
                                                    + str(config["bitcoin"]["rpcPort"]),
                                                    "--bookkeeper-dir=/rpc"
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
                                                "mountPath": lightning_dir,
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
