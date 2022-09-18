from helper import getDeploymentName, getServiceName, getVolumeClaimName
from kubernetes_cluster import cluster
from kubernetes_lightning_rest import lightning_rest

def api(config, cluster_types):
    kube_type_name = cluster(config)["kube_type_name"]
    base_name = config["env"] + "-api"
    lightning_rest_basename = lightning_rest(config, cluster_types)["base_name"]

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
                            {"port": config["api"]["port"], "name": "api"},
                            {"port": config["api"]["websocketPort"], "name": "api-ws"},
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
                        getVolumeClaimName(lightning_rest_basename + "-macaroon"),
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
                                        "image": "gcr.io/" + config["project"] + "/api:$SHORT_SHA",
                                        "resources": {"requests": {"cpu": "40m"}},
                                        "volumeMounts": [
                                            {
                                                "name": getVolumeClaimName(lightning_rest_basename + "-macaroon"),
                                                "mountPath": "usr/src/app/api/certs",
                                            },
                                        ],
                                    }
                                ],
                                "volumes": [
                                    {
                                        "name": getVolumeClaimName(lightning_rest_basename + "-macaroon"),
                                        "persistentVolumeClaim": {
                                            "claimName": getVolumeClaimName(lightning_rest_basename + "-macaroon")
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
