from kubernetes import GenerateConfig
from yaml import dump_all
import os 

class context:
    properties = {
        "env": "development"
    }
config = GenerateConfig(context())

minikube_resources = []
for resource in config["resources"]:
    if "type" in resource and config["cluster_types_root"] in resource["type"]:
        minikube_resources.append(resource["properties"])

# Order resources such that configs created first
def order(e):
    return e["kind"] in ["Ingress", "Secret", "ConfigMap", "PersistentVolumeClaim"]
minikube_resources.sort(reverse=True, key=order)

# Output resources to a yaml file
dir_path = os.path.dirname(os.path.realpath(__file__))
stream = open(dir_path + '/minikube.yaml', 'w')
dump_all(minikube_resources, stream, default_flow_style=False)