from helper import getConfigName, getServiceName, getVolumeClaimName
from kubernetes_cluster import cluster
from kubernetes_lightning_rest import lightning_rest


def ride_the_lightning(config, cluster_types):
    kube_type_name = cluster(config)["kube_type_name"]
    base_name = config["env"] + "-ride-the-lightning"
    lightning_rest_base_name = lightning_rest(config, cluster_types)["base_name"]

    return {
        "resources": [
            {
                "name": getConfigName(base_name),
                "type": cluster_types["ConfigMap"],
                "metadata": {"dependsOn": [kube_type_name]},
                "properties": {
                    "apiVersion": "v1",
                    "kind": "ConfigMap",
                    "metadata": {"name": "rtl-config.json", "namespace": "default"},
                    "namespace": "default",
                    "data": {
                        "rtl-config.json": """
{
  "port": """
   + str(config["rtl"]["port"]) 
   + """,
  "defaultNodeIndex": 1,
  "SSO": {
    "rtlSSO": 0,
    "rtlCookiePath": "",
    "logoutRedirectLink": ""
  },
  "nodes": [
    {
      "index": 1,
      "lnNode": "Node 1",
      "lnImplementation": "CLT",
      "Authentication": {
        "macaroonPath": "/RTL/certs"
      },
      "Settings": {
        "userPersona": "MERCHANT",
        "themeMode": "DAY",
        "themeColor": "PURPLE",
        "logLevel": "ERROR",
        "lnServerUrl": "http://"""
                        + getServiceName(lightning_rest_base_name)
                        + """:3001",
        "fiatConversion": false,
        "enableOffers": true
      },
      "enableOffers": true
    }
  ],
  "multiPass": "testing"
}
"""
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
                            {"port": config["rtl"]["port"], "name": "rtl"},
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
                        getVolumeClaimName(lightning_rest_base_name + "-macaroon"),
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
                                "containers": [
                                    {
                                        "name": base_name,
                                        "image": "shahanafarooqui/rtl:0.13.1",
                                        "command": ["/sbin/tini", "-g", "--", "sh", "-c", "ls && cp RTL-Config-Read-Only.json RTL-Config.json && node rtl"],
                                        "resources": {"requests": {"cpu": "40m"}},
                                        "volumeMounts": [
                                            {
                                                "mountPath": "RTL/RTL-Config-Read-Only.json",
                                                "subPath": "rtl-config.json",
                                                "name": "json-config",
                                            },
                                            {
                                                "name": getVolumeClaimName(lightning_rest_base_name + "-macaroon"),
                                                "mountPath": "RTL/certs",
                                            },
                                        ],
                                    }
                                ],
                                "volumes": [
                                    {
                                        "name": "json-config",
                                        "configMap": {"name": "rtl-config.json"},
                                    },
                                    {
                                        "name": getVolumeClaimName(lightning_rest_base_name + "-macaroon"),
                                        "persistentVolumeClaim": {
                                            "claimName": getVolumeClaimName(lightning_rest_base_name + "-macaroon")
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
