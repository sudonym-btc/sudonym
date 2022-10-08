from kubernetes_cluster import cluster

def storage(config, cluster_types):

    kube_type_name = cluster(config)["kube_type_name"]
    base_name = config["env"] + "-config"
    
    return {
        "resources": [{
                "type": "storage.v1.bucket",
                "name": base_name,
                "properties": {
                    "project": config["project"],
                    "location": "US-CENTRAL1",
                    "locationType": "region",
                    "iamConfiguration": {
                        "publicAccessPrevention": "enforced",
                        "uniformBucketLevelAccess": {
                            "enabled": True
                        },
                    },
                },
        }
        ]
    }