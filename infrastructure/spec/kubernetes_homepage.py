from helper import (
    getDeploymentName,
    getServiceName,
    getVolumeClaimName,
)
from kubernetes_cluster import cluster

def homepage(config, cluster_types):

    kube_type_name = cluster(config)["kube_type_name"]
    base_name = config["env"] + "-homepage"

    return {
        "resources": [
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
                            {"port": 8080, "name": "main"},
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
                        kube_type_name
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
                                        "image": "gcr.io/"
                                        + config["project"]
                                        + "/homepage",
                                        "ports": [
                                            {
                                                "containerPort": 8080,
                                                "name": "main",
                                            }
                                        ],
                                    }
                                ]
                            },
                        },
                    },
                },
            },
        ],
        "base_name": base_name,
    }
