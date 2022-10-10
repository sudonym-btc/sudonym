from helper import (
    getBackupName,
    getConfigName,
    getDeploymentName,
    getSecretName,
    getServiceName,
    getVolumeClaimName,
)
from kubernetes_cluster import cluster


def kubernetes_db(config, cluster_types):

    kube_type_name = cluster(config)["kube_type_name"]
    base_name = config["env"] + "-db"
    return {
        "resources": [
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
                        "storageClassName": "manual",
                        "accessModes": ["ReadWriteOnce"],
                        "resources": {
                            "requests": {
                            "storage": "20Gi"
                            }
                        }
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
                            {"port": 3306, "name": base_name},
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
                                "containers": [
                                    {
                                        "name": base_name,
                                        "image": "mysql:5.7",
                                        "args": ["-h", "0.0.0.0"],
                                        "env": [
                                            {
                                                "name": "MYSQL_ROOT_PASSWORD",
                                                "value": "testing"
                                            },
                                            {
                                                "name": "MYSQL_DATABASE",
                                                "value": "test"
                                            },
                                        ],
                                        "ports": [
                                            {
                                                "containerPort": 3306,
                                                "name": "mysql",
                                            }
                                        ],
                                        # "volumeMounts": [
                                        #     {
                                        #         "name": getVolumeClaimName(base_name),
                                        #         "mountPath": "/var/lib/mysql",
                                        #     }
                                        # ],
                                    }
                                ],
                                # "volumes": [
                                #     {
                                #         "name": getVolumeClaimName(base_name),
                                #         "persistentVolumeClaim": {
                                #             "claimName": getVolumeClaimName(base_name)
                                #         },
                                #     }
                                # ],
                            },
                        },
                    },
                },
            },
            {
                "name": getServiceName(base_name + '-phpmyadmin'),
                "type": cluster_types["Service"],
                "metadata": {"dependsOn": [kube_type_name]},
                "properties": {
                    "apiVersion": "v1",
                    "kind": "Service",
                    "namespace": "default",
                    "metadata": {
                        "name": getServiceName(base_name + '-phpmyadmin'),
                        "labels": {"app": base_name + '-phpmyadmin'},
                    },
                    "spec": {
                        "type": "NodePort",
                        "ports": [
                            {"port": 80, "name": base_name + '-phpmyadmin'},
                        ],
                        "selector": {"app": base_name  + '-phpmyadmin'},
                    },
                },
            },
            {
                "name": getDeploymentName(base_name + '-phpmyadmin'),
                "type": cluster_types["Deployment"],
                "metadata": {
                    "dependsOn": [
                        kube_type_name
                    ]
                },
                "properties": {
                    "apiVersion": "apps/v1",
                    "kind": "Deployment",
                    "namespace": "default",
                    "metadata": {
                        "name": getDeploymentName(base_name+ '-phpmyadmin'),
                        "labels": {"app": base_name + '-phpmyadmin'},
                    },
                    "spec": {
                        "strategy": {"type": "Recreate"},
                        "replicas": 1,
                        "selector": {"matchLabels": {"app": base_name + '-phpmyadmin'}},
                        "template": {
                            "metadata": {"labels": {"app": base_name + '-phpmyadmin'}},
                            "spec": {
                                "containers": [
                                    {
                                        "name": base_name + '-phpmyadmin',
                                        "image": "phpmyadmin/phpmyadmin",
                                        "env": [
                                            {
                                                "name": "MYSQL_ROOT_PASSWORD",
                                                "value": "testing"
                                            },
                                            {
                                                "name": "MYSQL_DATABASE",
                                                "value": "test"
                                            },
                                            {
                                                "name": "PMA_HOST",
                                                "value": getServiceName(base_name)
                                            },
                                            {
                                                "name": "PMA_PORT",
                                                "value": "3306"
                                            },
                                        ],
                                        "ports": [
                                            {
                                                "containerPort": 80,
                                                "name": "phpmyadmin",
                                            }
                                        ],
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
