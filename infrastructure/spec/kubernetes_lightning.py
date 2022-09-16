from helper import getServiceName, getVolumeClaimName
from kubernetes_cluster import cluster
from kubernetes_bitcoin import bitcoin


def lightning(config, cluster_types):
    kube_type_name = cluster(config)["kube_type_name"]
    bitcoin_base_name = bitcoin(config, cluster_types)["base_name"]
    base_name = config["env"] + "-lightning"

    return {
        "resources": [
            {
                "type": "storage.v1.bucket",
                "name": "sudonym-" + base_name + "-backup",
                "properties": {
                    "project": config["project"],
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
                        "resources": {"requests": {"storage": "10Gi"}},
                    },
                },
            },
            {
                "name": getVolumeClaimName(base_name + "-backup"),
                "type": cluster_types["PersistentVolumeClaim"],
                "metadata": {"dependsOn": [kube_type_name]},
                "properties": {
                    "apiVersion": "v1",
                    "kind": "PersistentVolumeClaim",
                    "namespace": "default",
                    "metadata": {"name": getVolumeClaimName(base_name + "-backup")},
                    "spec": {
                        "accessModes": ["ReadWriteOnce"],
                        "resources": {"requests": {"storage": "10Gi"}},
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
                            {"port": config["lightning"]["port"], "name": base_name},
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
                        getVolumeClaimName(base_name),
                        getServiceName(base_name + "-backup")
                    ],
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
                                        "image": "gcr.io/sudonym-lightning-test/fuse-lightning",
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
                                                    "--addr=0.0.0.0:" + str(config["lightning"]["port"]),
                                                    "--experimental-offers",
                                                    "--network=" + config["network"],
                                                    "--wallet=sqlite3:///lightning/"
                                                    + config["network"]
                                                    + "/lightningd.sqlite3",
                                                    "--bitcoin-rpcport=" + str(config["bitcoin"]["rpcPort"]),
                                                ]
                                            ),
                                        ],
                                        "env": [
                                            {"name": "EXPOSE_TCP", "value": "true"},
                                            {
                                                "name": "BITCOIN_RPC_USER",
                                                "valueFrom": {
                                                    "secretKeyRef": {
                                                        "name": bitcoin_base_name
                                                        + "-secret",
                                                        "key": "rpcuser",
                                                    }
                                                },
                                            },
                                            {
                                                "name": "BITCOIN_RPC_PASSWORD",
                                                "valueFrom": {
                                                    "secretKeyRef": {
                                                        "name": bitcoin_base_name
                                                        + "-secret",
                                                        "key": "rpcpass",
                                                    }
                                                },
                                            },
                                        ],
                                        "ports": [
                                            {"containerPort": config["lightning"]["port"], "name": "ln"},
                                        ],
                                        "volumeMounts": [
                                            {
                                                "name": base_name + "-data",
                                                "mountPath": "/rpc",
                                            },
                                            {
                                                "name": base_name + "-backup-data",
                                                "mountPath": "/lightning",
                                            },
                                        ],
                                    }
                                ],
                                "volumes": [
                                    {
                                        "name": base_name + "-data",
                                        "persistentVolumeClaim": {
                                            "claimName": base_name + "-volume-claim"
                                        },
                                    },
                                    {
                                        "name": base_name + "-backup-data",
                                        "persistentVolumeClaim": {
                                            "claimName": base_name
                                            + "-backup-volume-claim"
                                        },
                                    },
                                ],
                            },
                        },
                    },
                },
            },
        ]
        + (
            [
                {
                    "name": base_name + "-1-service",
                    "type": cluster_types["Service"],
                    "metadata": {"dependsOn": [kube_type_name]},
                    "properties": {
                        "apiVersion": "v1",
                        "kind": "Service",
                        "namespace": "default",
                        "metadata": {
                            "name": base_name + "-1-service",
                            "labels": {"app": base_name + "-1"},
                        },
                        "spec": {
                            "type": "NodePort",
                            "ports": [
                                {"port": config["lightning"]["port"], "name": base_name + "-1"},
                            ],
                            "selector": {"app": base_name + "-1"},
                        },
                    },
                },
                {
                    "name": base_name + "-1",
                    "type": cluster_types["Deployment"],
                    "properties": {
                        "apiVersion": "apps/v1",
                        "kind": "Deployment",
                        "namespace": "default",
                        "metadata": {
                            "name": base_name + "-1",
                            "labels": {"app": base_name + "-1"},
                        },
                        "spec": {
                            "strategy": {"type": "Recreate"},
                            "replicas": 1,
                            "selector": {"matchLabels": {"app": base_name + "-1"}},
                            "template": {
                                "metadata": {"labels": {"app": base_name + "-1"}},
                                "spec": {
                                    "containers": [
                                        {
                                            "name": base_name + "-1",
                                            "image": "elementsproject/lightningd:latest",
                                            "resources": {"requests": {"cpu": "40m"}},
                                            "args": [
                                                "--bitcoin-rpcuser=$(BITCOIN_RPC_USER)",
                                                "--bitcoin-rpcpassword=$(BITCOIN_RPC_PASSWORD)",
                                                "--bitcoin-rpcconnect="
                                                + bitcoin_base_name
                                                + "-service",
                                                "--log-level=debug",
                                                "--addr=0.0.0.0:9735",
                                                "--experimental-offers",
                                            ]
                                            + (
                                                [
                                                    "--network=regtest",
                                                    "--bitcoin-rpcport=" + str(config["bitcoin"]["rpcPort"]),
                                                ]
                                                if config["env"] == "development"
                                                else []
                                            ),
                                            "env": [
                                                {"name": "EXPOSE_TCP", "value": "true"},
                                                {
                                                    "name": "BITCOIN_RPC_USER",
                                                    "valueFrom": {
                                                        "secretKeyRef": {
                                                            "name": bitcoin_base_name
                                                            + "-secret",
                                                            "key": "rpcuser",
                                                        }
                                                    },
                                                },
                                                {
                                                    "name": "BITCOIN_RPC_PASSWORD",
                                                    "valueFrom": {
                                                        "secretKeyRef": {
                                                            "name": bitcoin_base_name
                                                            + "-secret",
                                                            "key": "rpcpass",
                                                        }
                                                    },
                                                },
                                            ],
                                            "ports": [
                                                {"containerPort": 9735, "name": "ln1"},
                                            ],
                                        }
                                    ]
                                },
                            },
                        },
                    },
                },
                # SECOND CHANNEL
                {
                    "name": base_name + "-2-service",
                    "type": cluster_types["Service"],
                    "metadata": {"dependsOn": [kube_type_name]},
                    "properties": {
                        "apiVersion": "v1",
                        "kind": "Service",
                        "namespace": "default",
                        "metadata": {
                            "name": base_name + "-2-service",
                            "labels": {"app": base_name + "-2"},
                        },
                        "spec": {
                            "type": "NodePort",
                            "ports": [
                                {"port": config["lightning"]["port"], "name": base_name + "-2"},
                            ],
                            "selector": {"app": base_name + "-2"},
                        },
                    },
                },
                {
                    "name": base_name + "-2",
                    "type": cluster_types["Deployment"],
                    "properties": {
                        "apiVersion": "apps/v1",
                        "kind": "Deployment",
                        "namespace": "default",
                        "metadata": {
                            "name": base_name + "-2",
                            "labels": {"app": base_name + "-2"},
                        },
                        "spec": {
                            "strategy": {"type": "Recreate"},
                            "replicas": 1,
                            "selector": {"matchLabels": {"app": base_name + "-2"}},
                            "template": {
                                "metadata": {"labels": {"app": base_name + "-2"}},
                                "spec": {
                                    # "initContainers": [
                                    #     {
                                    #         "image": "projects.registry.vmware.com/tcx/snapshot/stackanetes/kubernetes-entrypoint:latest",
                                    #         "command": ["kubernetes-entrypoint"],
                                    #         "name": "init-dependency-check",
                                    #         "env": [
                                    #             {
                                    #                 "name": "POD_NAME",
                                    #                 "valueFrom": {
                                    #                     "fieldRef": {
                                    #                         "apiVersion": "v1",
                                    #                         "fieldPath": "metadata.name"
                                    #                     }
                                    #                 }
                                    #             },
                                    #             {
                                    #                 "name": "NAMESPACE",
                                    #                 "valueFrom": {
                                    #                     "fieldRef": {
                                    #                         "apiVersion": "v1",
                                    #                         "fieldPath": "metadata.namespace"
                                    #                     }
                                    #                 }
                                    #             },
                                    #             {
                                    #                 "name": "DEPENDENCY_CONTAINER",
                                    #                 "value": bitcoin_base_name
                                    #             },
                                    #             {
                                    #                 "name": "COMMAND",
                                    #                 "value": "echo done"
                                    #             }
                                    #     ],
                                    #         "securityContext": {
                                    #             "privileged": True,
                                    #             "runAsUser": 0
                                    #         }
                                    #     }
                                    # ],
                                    "containers": [
                                        {
                                            "name": base_name + "-2",
                                            "image": "gcr.io/sudonym-lightning-test/fuse-lightning",
                                            "resources": {"requests": {"cpu": "40m"}},
                                            "args": [
                                                "--bitcoin-rpcuser=$(BITCOIN_RPC_USER)",
                                                "--bitcoin-rpcpassword=$(BITCOIN_RPC_PASSWORD)",
                                                "--bitcoin-rpcconnect="
                                                + bitcoin_base_name
                                                + "-service",
                                                "--log-level=debug",
                                                "--addr=0.0.0.0:9735",
                                                "--experimental-offers",
                                            ]
                                            + (
                                                [
                                                    "--network=regtest",
                                                    "--bitcoin-rpcport=" + str(config["bitcoin"]["rpcPort"]),
                                                ]
                                                if config["env"] == "development"
                                                else []
                                            ),
                                            "env": [
                                                {"name": "EXPOSE_TCP", "value": "true"},
                                                {
                                                    "name": "BITCOIN_RPC_USER",
                                                    "valueFrom": {
                                                        "secretKeyRef": {
                                                            "name": bitcoin_base_name
                                                            + "-secret",
                                                            "key": "rpcuser",
                                                        }
                                                    },
                                                },
                                                {
                                                    "name": "BITCOIN_RPC_PASSWORD",
                                                    "valueFrom": {
                                                        "secretKeyRef": {
                                                            "name": bitcoin_base_name
                                                            + "-secret",
                                                            "key": "rpcpass",
                                                        }
                                                    },
                                                },
                                            ],
                                            "ports": [
                                                {"containerPort": 9735, "name": "ln1"},
                                            ],
                                        }
                                    ]
                                },
                            },
                        },
                    },
                },
            ]
            if config["env"] == "development"
            else []
        ),
        "base_name": base_name,
    }
