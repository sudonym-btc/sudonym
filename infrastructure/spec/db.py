from kubernetes_cluster import cluster

def db(config, cluster_types):

    kube_type_name = cluster(config)["kube_type_name"]
    base_name = config["env"] + "-db"
    
    return {
        "resources": [
          {
            "name": base_name,
            "type": "gcp-types/sqladmin-v1beta4:instances",
            "properties": {
                "region": "us-central1",
                "settings": {
                  "tier": "db-custom-1-3840",
                    "backupConfiguration": {
                        "enabled": True
                    }
                }
            }
          },
          {
            "name": base_name + "-database",
            "metadata": {
              "dependsOn": [base_name]
            },
            "type": "gcp-types/sqladmin-v1beta4:databases",
            "properties": {
                "name": "app",
                "instance": f"$(ref.{base_name}.name)",
                "charset": "utf8"
            }
          },
          # {
          #   "name": base_name + "-user",
          #   "type": "gcp-types/sqladmin-v1beta4:users",
          #   "properties": {
          #       "instance": f"$(ref.{base_name}.name)",
          #       "host": "%",
          #       "name": "test",
          #       "password": "test"
          #   }
          # }
        ],
        "base_name": base_name,
    }