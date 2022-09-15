from kubernetes_cluster import cluster
from kubernetes_lightning_rest import lightning_rest

def api(config, cluster_types):
    kube_type_name = cluster(config)["kube_type_name"]
    base_name = config["env"] + "-api"
    lightning_rest_basename = lightning_rest(config, cluster_types)["base_name"]

    return {
        "resources": [
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
                            {"port": 3000, "name": "api"},
                            {"port": 3001, "name": "api-ws"},
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
                        "macaroon-volume-claim",
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
                                "initContainers":[{
                                    "name": "wait",
                                    "image": "busybox",
                                    "command":  ["sh", "-c", "until nc -z " + lightning_rest_basename + "-service 3001 > /dev/null; do echo Waiting for master.; sleep 2; done;"]
                                }],
                               "containers": [
                                    {
                                        "name": base_name,
                                        "image": "gcr.io/" + config["project"] + "/api:latest",
                                        "resources": {"requests": {"cpu": "40m"}},
                                        "volumeMounts": [
                                            {
                                                "name": "macaroon-data",
                                                "mountPath": "usr/src/app/api/certs",
                                            },
                                        ],
                                    }
                                ],
                                "volumes": [
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
