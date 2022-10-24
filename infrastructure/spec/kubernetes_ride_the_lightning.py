from helper import getConfigName, getServiceName, getVolumeClaimName, getSecretName
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
        "macaroonPath": "/RTL/certs1"
      },
      "Settings": {
        "userPersona": "MERCHANT",
        "themeMode": "DAY",
        "themeColor": "PURPLE",
        "logLevel": "ERROR",
        "lnServerUrl": "http://"""
                        + getServiceName(lightning_rest_base_name, 1)
                        + """:3001",
        "fiatConversion": false,
        "enableOffers": true
      },
      "enableOffers": true
    },
    {
      "index": 2,
      "lnNode": "Node 2",
      "lnImplementation": "CLT",
      "Authentication": {
        "macaroonPath": "/RTL/certs2"
      },
      "Settings": {
        "userPersona": "MERCHANT",
        "themeMode": "DAY",
        "themeColor": "PURPLE",
        "logLevel": "ERROR",
        "lnServerUrl": "http://"""
                        + getServiceName(lightning_rest_base_name, 2)
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
                        getVolumeClaimName(lightning_rest_base_name + "-macaroon", 1),
                    ] + ([
                        getVolumeClaimName(lightning_rest_base_name + "-macaroon", 2)
                        ] if config["env"] != "production" else [])
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
                                        "command": ["/sbin/tini", "-g", "--", "sh", "-c", 'echo $RTL_PASS && cp RTL-Config-Read-Only.json RTL-Config.json && sed "s:testing:$RTL_PASS:g" -i RTL-Config.json && node rtl'],
                                        "env": [{
                                            "name": "RTL_PASS",
                                            "valueFrom": {
                                                "secretKeyRef": {
                                                    "name": config["env"] + "-ride-the-lightning-secret",
                                                    "key": "key.txt",
                                                    "optional": False
                                                }
                                            }
                                        }],
                                        "volumeMounts": [
                                            {
                                                "mountPath": "RTL/RTL-Config-Read-Only.json",
                                                "subPath": "rtl-config.json",
                                                "name": "json-config",
                                            },
                                            {
                                                "name": getVolumeClaimName(lightning_rest_base_name + "-macaroon", 1),
                                                "mountPath": "RTL/certs1",
                                            },
                                            
                                        ] + ([{
                                                "name": getVolumeClaimName(lightning_rest_base_name + "-macaroon", 2),
                                                "mountPath": "RTL/certs2",
                                            }] if config["env"] != "production" else []),
                                    }
                                ],
                                "volumes": [
                                    {
                                        "name": "json-config",
                                        "configMap": {"name": "rtl-config.json"},
                                    },
                                    {
                                        "name": getVolumeClaimName(lightning_rest_base_name + "-macaroon", 1),
                                        "persistentVolumeClaim": {
                                            "claimName": getVolumeClaimName(lightning_rest_base_name + "-macaroon", 1)
                                        },
                                    },
                                    
                                ] + ([{
                                        "name": getVolumeClaimName(lightning_rest_base_name + "-macaroon", 2),
                                        "persistentVolumeClaim": {
                                            "claimName": getVolumeClaimName(lightning_rest_base_name + "-macaroon", 2)
                                        },
                                    },] if config["env"] != "production" else []),
                            },
                        },
                    },
                },
            },
        ] + ([ {
                "name": getSecretName(base_name),
                "type": cluster_types["Secret"],
                "metadata": {"dependsOn": [kube_type_name]},
                "properties": {
                    "apiVersion": "v1",
                    "kind": "Secret",
                    "namespace": "default",
                    "metadata": {"name": base_name + "-secret"},
                    "type": "Opaque",
                    "data": {"pass": "dGVzdGluZw=="}, # Default development password "testing"
                },
            },] if config["env"] == "development" else []),
        "base_name": base_name,
    }
