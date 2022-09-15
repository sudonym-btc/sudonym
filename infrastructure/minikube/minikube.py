import os
import sys
import inspect


# Add the spec folder to path, as py will only find files in same folder
currentdir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
parentdir = os.path.dirname(currentdir)
sys.path.insert(0, parentdir) 
sys.path.insert(0, parentdir + "/spec") 

from spec.kubernetes import GenerateConfig
from yaml import dump_all, dump
import os 
from random import seed
from random import random
# seed random number generator
seed(1)

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

print("Generated resources for minikube...")
# print(minikube_resources)
print()

# Make image pull for API local.
for idx, item in enumerate(minikube_resources):
    if item["metadata"]["name"] == "development-api-deployment":
        item["spec"]["template"]["spec"]["containers"][0]["imagePullPolicy"] = "IfNotPresent"
        item["spec"]["template"]["spec"]["containers"][0]["image"] = "api"
        item["spec"]["template"]["spec"]["containers"][0]["command"] = ["npm", "run", "start:dev"]


# Output resources to a yaml file
dir_path = os.path.dirname(os.path.realpath(__file__))
stream = open(dir_path + '/minikube.yaml', 'w')
dump_all(minikube_resources, stream, default_flow_style=False)