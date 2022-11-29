from helper import (getDeploymentName, getSecretName, getServiceName,
                    getVolumeClaimName)
from kubernetes_cluster import cluster
from kubernetes_lightning_rest import lightning_rest


def api(config, cluster_types):
    kube_type_name = cluster(config)["kube_type_name"]
    base_name = config["env"] + "-api"
    lightning_rest_basename = lightning_rest(config, cluster_types)["base_name"]

    return {
        "resources": [
            {
                "name": base_name + "-service-account",
                "type": cluster_types["ServiceAccount"],
                "metadata": {"dependsOn": [kube_type_name]},
                "properties": {
                    "apiVersion": "v1",
                    "kind": "ServiceAccount",
                    "namespace": "default",
                    "metadata": {
                        "name": "api"
                    }
                }
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
                        "strategy": {"type": "RollingUpdate"},
                        "rollingUpdate": {
                            "maxSurge": 1
                        },
                        "replicas": 1,
                        "selector": {"matchLabels": {"app": base_name}},
                        "template": {
                            "metadata": {
                                "labels": {"app": base_name},
                            },
                            "spec": {
                                "serviceAccountName": "api",
                                "initContainers": [
                                    {
                                        "name": "wait",
                                        "image": "busybox",
                                        "command": [
                                            "sh",
                                            "-c",
                                            "until nc -z "
                                            + getServiceName(lightning_rest_basename)
                                            + " 3001 > /dev/null; do echo Waiting for master.; sleep 2; done;",
                                        ],
                                    }
                                ],
                                "containers": [
                                    dict({
                                        "name": base_name,
                                        "image": "gcr.io/"
                                        + config["project"]
                                        + "/api:latest",
                                        "env": [
                                            {
                                                "name": "DB_PASS",
                                                "valueFrom": {
                                                    "secretKeyRef": {
                                                        "name": config["env"] + '-db-secret',
                                                        "key": "key.txt",
                                                        "optional": False
                                                    }
                                                }
                                            },
                                            {"name": "NODE_ENV", "value": config["env"]}
                                        ],
                                        "volumeMounts": [
                                            {
                                                "name": getVolumeClaimName(
                                                    lightning_rest_basename
                                                    + "-macaroon"
                                                ),
                                                "mountPath": "usr/src/app/api/certs",
                                            },
                                        ],
                                        "readinessProbe": {
                                            "httpGet": {
                                                "port": config["api"]["port"]
                                            }
                                        }
                                       
                                    }, **({
                                        "image": "api",
                                        "imagePullPolicy": "IfNotPresent",
                                        "command": ["npm", "run", "start:dev"]
                                    } if config["env"] == "development" else {}))
                                ] + ([{
                                    "name": "cloud-sql-proxy",
                                    "image": "gcr.io/cloudsql-docker/gce-proxy:1.32.0", # make sure the use the latest version
                                    "command": [ "/cloud_sql_proxy", "-log_debug_stdout", "-instances=" + config["project"] + ":us-central1:production-db=tcp:3306" ],
                                    "securityContext": {
                                        "runAsNonRoot": True
                                    },
                                    "resources": {
                                        "requests": {
                                        #   memory: "2Gi"
                                        #   cpu:    "1"
                                        }
                                    }
                                }] if config["env"] != "development" else []),
                                "volumes": [
                                    {
                                        "name": getVolumeClaimName(
                                            lightning_rest_basename + "-macaroon"
                                        ),
                                        "persistentVolumeClaim": {
                                            "claimName": getVolumeClaimName(
                                                lightning_rest_basename + "-macaroon"
                                            )
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
