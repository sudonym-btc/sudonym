#
# This is modified version of code provided by Google at:
# https://github.com/GoogleCloudPlatform/deploymentmanager-samples
#

from common import getConfig
from storage import storage
from dns import dns
from db import db
from kubernetes_ingress import ingress
from kubernetes_db import kubernetes_db
from kubernetes_ride_the_lightning import ride_the_lightning
from kubernetes_lightning_rest import lightning_rest
from kubernetes_cluster import cluster
from kubernetes_bitcoin import bitcoin
from kubernetes_lightning import lightning
from kubernetes_lightning_rest import lightning_rest
from kubernetes_api import api
from kubernetes_homepage import homepage
from kubernetes_web import web


def GenerateConfig(context):

    config = getConfig(context.properties["env"])
    kube_type_name = cluster(config)["kube_type_name"]

    cluster_types_root = "".join([config["project"], "/", kube_type_name])
    cluster_types = {
        "Service": "".join(
            [cluster_types_root, ":", "/api/v1/namespaces/{namespace}/services/{name}"]
        ),
        "ServiceAccount": "".join(
            [
                cluster_types_root,
                ":",
                "/api/v1/namespaces/{namespace}/serviceaccounts/{name}",
            ]
        ),
        "ConfigMap": "".join(
            [
                cluster_types_root,
                ":",
                "/api/v1/namespaces/{namespace}/configmaps/{name}",
            ]
        ),
        "Deployment": "".join(
            [
                cluster_types_root,
                ":",
                "/apis/apps/v1/namespaces/{namespace}/deployments/{name}",
            ]
        ),
        "PersistentVolumeClaim": "".join(
            [
                cluster_types_root,
                ":",
                "/api/v1/namespaces/{namespace}/persistentvolumeclaims/{name}",
            ]
        ),
        "Secret": "".join(
            [
                cluster_types_root,
                ":",
                "/api/v1/namespaces/{namespace}/secrets/{name}",
            ]
        ),
        "Ingress": "".join(
            [
                cluster_types_root,
                ":",
                "/apis/networking.k8s.io/v1/namespaces/{namespace}/ingresses/{name}",
            ]
        )
    }

    resources = (
        cluster(config)["resources"]
        + ingress(config, cluster_types)["resources"]
        + bitcoin(config, cluster_types)["resources"]
        + lightning(config, cluster_types)["resources"]
        + lightning_rest(config, cluster_types)["resources"]
        + ride_the_lightning(config, cluster_types)["resources"]
        + api(config, cluster_types)["resources"]
        + dns(config, cluster_types)["resources"]
        + storage(config, cluster_types)["resources"]
        + homepage(config, cluster_types)["resources"]
        + web(config, cluster_types)["resources"]
    ) + (
        kubernetes_db(config, cluster_types)["resources"] if config["env"] in ["development", "test"] else db(config, cluster_types)["resources"] 
    )
    print(resources)
    return {"resources": resources, "cluster_types_root": cluster_types_root}
