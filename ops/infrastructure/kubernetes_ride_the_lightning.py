from kubernetes_cluster import cluster
from kubernetes_lightning_rest import lightning_rest


def ride_the_lightning(config, cluster_types):
    kube_type_name = cluster(config)["kube_type_name"]
    base_name = config["env"] + "-ride-the-lightning"
    lightning_rest_basename = lightning_rest(config, cluster_types)["base_name"]

    return {
        "resources": [
            {
                "name": base_name + "-config",
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
  "port": "3000",
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
        "lnServerUrl": "https://"""
                        + lightning_rest_basename
                        + """-service:3001",
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
                            {"port": 3000, "name": "rtl"},
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
                                "containers": [
                                    {
                                        "name": base_name,
                                        "image": "shahanafarooqui/rtl:0.12.1",
                                        "command": ["/sbin/tini", "-g", "--", "sh", "-c", "ls && cp RTL-Config-Read-Only.json RTL-Config.json && node rtl"],
                                        "resources": {"requests": {"cpu": "40m"}},
                                        "volumeMounts": [
                                            {
                                                "mountPath": "RTL/RTL-Config-Read-Only.json",
                                                "subPath": "rtl-config.json",
                                                "name": "json-config",
                                            },
                                            {
                                                "name": "macaroon-data",
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
