import inspect
import os
import sys

# Add the spec folder to path, as py will only find files in same folder
currentdir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
parentdir = os.path.dirname(currentdir)
sys.path.insert(0, parentdir) 
sys.path.insert(0, parentdir + "/spec") 

import os
from random import random, seed

from spec.kubernetes import GenerateConfig
from yaml import dump, dump_all

# seed random number generator
seed(1)

class context:
    properties = {
        "env": sys.argv[1] if len(sys.argv) > 1 else "development"
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

# Print resource name
for idx, item in enumerate(minikube_resources):
    print(item["metadata"]["name"])


# Output resources to a yaml file
dir_path = os.path.dirname(os.path.realpath(__file__))
stream = open(dir_path + '/minikube.yaml', 'w')
dump_all(minikube_resources, stream, default_flow_style=False)