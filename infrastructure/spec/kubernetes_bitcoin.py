from kubernetes_cluster import cluster


def bitcoin(config, cluster_types):

    kube_type_name = cluster(config)["kube_type_name"]
    base_name = config["env"] + "-bitcoin"
    return {
        "resources": [
            {
                "type": "storage.v1.bucket",
                "name": "sudonym-" + base_name + "-backup",
                "properties": {
                    "project": "sudonym-lightning-test",
                    "name": "sudonym-" + base_name
                }
            },
            {
                "name": base_name + "-secret",
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
                        "resources": {"requests": {"storage": "500Gi"}},
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
                    "metadata": {"name": base_name + "-service", "labels": {"app": base_name}},
                    "spec": {
                        "type": "NodePort",
                        "ports": [
                            {"port": 8332, "name": "rpc"},
                            {"port": 8333, "name": base_name},
                        ],
                        "selector": {"app": base_name},
                    },
                },
            },
            {
                "name": base_name + "-zeromq-service",
                "type": cluster_types["Service"],
                "metadata": {"dependsOn": [kube_type_name]},
                "properties": {
                    "apiVersion": "v1",
                    "kind": "Service",
                    "namespace": "default",
                    "metadata": {"name": base_name + "-zeromq-service", "labels": {"app": base_name}},
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
                "name": base_name + "-deployment",
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
                                "securityContext": {
                                    "privileged": True,
                                    "capabilities": {
                                        "add": ["SYS_ADMIN"]
                                    }
                                },
                                "lifecycle": {
                                    "postStart": {
                                        "exec": {
                                        "command": ["gcsfuse", "-o", "nonempty", "sudonym-development-bitcoin-backup", "/etc/bla"]
                                        }
                                    },
                                    "preStop": {
                                        "exec": {
                                        "command": ["fusermount", "-u", "/etc/bla"],
                                        }
                                    },
                                },
                                "containers": [
                                    {
                                        "name": base_name,
                                        "image": "ruimarinho/bitcoin-core:23.0",
                                        "resources": {"requests": {"cpu": "40m"}},
                                        "command": ["bitcoind"], # gcsfuse -o nonempty sudonym-development-bitcoin-backup /etc/bla
                                        "args": [
                                            "-server",
                                            "-rest",
                                            "-txindex",
                                            "-datadir=/bitcoin/.bitcoin",
                                            "-port=8333",
                                            "-rpcuser=$(BITCOIN_RPC_USER)",
                                            "-rpcpassword=$(BITCOIN_RPC_PASSWORD)",
                                            "-rpcallowip=0.0.0.0/0",
                                            "-rpcallowip=::/0",
                                            "-rpcport=8332",
                                            "-rpcbind=0.0.0.0",
                                            "-rpcbind=" + base_name,
                                            "-zmqpubrawtx=tcp://*:5555",
                                            "-zmqpubhashblock=tcp://*:5555",
                                            "-zmqpubhashtx=tcp://*:5555",
                                            "-zmqpubrawblock=tcp://*:5555",
                                            "-debug=1",
                                        ]
                                        + (
                                            ["-regtest=1"]
                                            if config["env"] == "development"
                                            else []
                                        )
                                        + (
                                            ["-testnet=1"]
                                            if config["env"] == "testing"
                                            else []
                                        ),
                                        "env": [
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
                                            {"containerPort": 8332, "name": "rpc"},
                                            {"containerPort": 8333, "name": "bitcoin"},
                                            {
                                                "containerPort": 5555,
                                                "name": "zeromq",
                                            },
                                        ],
                                        "volumeMounts": [
                                            {
                                                "name": base_name + "-data",
                                                "mountPath": "/bitcoin/.bitcoin",
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
