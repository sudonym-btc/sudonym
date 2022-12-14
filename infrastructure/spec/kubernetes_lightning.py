from helper import (addNum, getBackupName, getDeploymentName, getSecretName,
                    getServiceName, getVolumeClaimName)
from kubernetes_bitcoin import bitcoin
from kubernetes_cluster import cluster


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
        lightning_dir = "/root/.lightning"
        lightning_recovery_file = f"{lightning_dir}/{chain_name}/emergency.recover"
        backup_dir = "/backup"
        bucket = "sudonym-" + getBackupName(base_name, num)
        backup_recovery_file = f"{backup_dir}/emergency.recover"

        print(lightning_recovery_file)
        print(backup_recovery_file)
        
        mount = f"""mkdir -p {backup_dir} &&
            echo $(gcsfuse --limit-ops-per-sec=10 {gcs_log} {bucket} {backup_dir}) &&
            [ -f "{backup_recovery_file}" ] && cp {backup_recovery_file} {lightning_recovery_file} && \
            (while true;
            do 
                cp -u {lightning_recovery_file} {backup_dir}
                sleep 1 &
            done;)"""

        unmount = f"""fusermount -u {backup_dir}"""

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
                "name": getServiceName(base_name + "-pub", num),
                "type": cluster_types["Service"],
                "metadata": {"dependsOn": [kube_type_name,config["env"] + "-ip"]},
                "properties": {
                    "apiVersion": "v1",
                    "kind": "Service",
                    "namespace": "default",
                    "metadata": {
                        "name": getServiceName(base_name + "-pub", num),
                        "labels": {
                            "app": addNum(base_name + "-pub", num)
                        },
                    },
                    "spec": {
                        "selector": {"app": addNum(base_name, num)},
                        "ports": [{
                            "port":  config["lightning"]["port"],
                            "targetPort":  config["lightning"]["port"]
                        }],
                        "type": "LoadBalancer",
                        "loadBalancerIP": "$(ref." + config["env"] + "-ip.address)"
                    }
                }
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
                                        "serviceAccountName": "lightning",
                                        "securityContext": {
                                            "privileged": True,
                                            "capabilities": {"add": ["SYS_ADMIN"]},
                                        },
                                        "lifecycle": {
                                            # "postStart": {
                                            #     "exec": {
                                            #         "command": [
                                            #             '/bin/sh',
                                            #             '-c',
                                            #             mount,
                                            #             " >> /proc/1/fd/1"
                                            #         ],
                                            #     }
                                            # },
                                            "preStop": {
                                                "exec": {
                                                    "command": [
                                                        '/bin/sh',
                                                        '-c',
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
                                                f"{mount} &"
                                                if config["backup"]
                                                else ""
                                            )
                                            + " ./entrypoint.sh "
                                            + " ".join([
                                            "--alias=" + config["appName"] + addNum(("-" + config["env"]) if config["env"] != "production" else "", num),
                                            "--bitcoin-rpcuser=$(BITCOIN_RPC_USER)",
                                            "--bitcoin-rpcpassword=$(BITCOIN_RPC_PASSWORD)",
                                            "--bitcoin-rpcconnect="
                                            + getServiceName(bitcoin_base_name),
                                            "--bitcoin-rpcport="
                                            + str(config["bitcoin"]["rpcPort"]),
                                            "--log-level=" + config["loglevel"],
                                            "--lightning-dir=" + lightning_dir,
                                            "--rpc-file=/rpc/lightning-rpc",
                                            "--large-channels",
                                            "--bind-addr=0.0.0.0:"
                                            + str(config["lightning"]["port"]),
                                            "--experimental-offers",
                                            "--network=" + chain_name,
                                        ] + ([
                                            "--announce-addr=34.67.91.68:" + str(config["lightning"]["port"]),
                                            # "--announce-addr-dns=1"
                                            ] if config["env"] == "production" else []))],
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

                                        "resources": {
                                            # "limits": {
                                            #     "cpu": "0.1",
                                            #     "memory": "750Mi"
                                            # },
                                            "requests": {
                                                "cpu": "0.01",
                                                "memory": "400Mi"
                                            }
                                        }
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
        "resources": getResource(1) + (getResource(2) + getResource(3) if config["env"] == "development" else []),
        "base_name": base_name,
    }
