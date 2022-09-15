import os
from yaml import dump_all, load_all, Loader
import json

resources = []
# Output resources to a yaml file
dir_path = os.path.dirname(os.path.realpath(__file__))
for data in load_all(open(dir_path + "/cert-manager.yaml", "r"), Loader):
    resources.append(data)
print(resources)
# json_string = json.dumps(resources)

with open('json_data.json', 'w') as outfile:
    json.dump(resources, outfile)