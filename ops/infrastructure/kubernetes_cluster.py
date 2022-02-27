"""Create configuration to deploy GKE cluster."""


def cluster(
    config,
):
    base_name = config["env"] + "-cluster"
    kube_type_name = base_name + "-type"

    resources = [
        {
            "name": base_name,
            "type": "container.v1.cluster",
            "properties": {
                "zone": config["zone"],
                "cluster": {
                    "name": base_name,
                    "initialNodeCount": 1,
                    "nodeConfig": {
                        "oauthScopes": [
                            "https://www.googleapis.com/auth/" + s
                            for s in [
                                "compute",
                                "devstorage.read_only",
                                "logging.write",
                                "monitoring",
                            ]
                        ]
                    },
                },
            },
        },
        {
            "name": kube_type_name,
            "type": "deploymentmanager.v2beta.typeProvider",
            "metadata": {"dependsOn": [base_name]},
            "properties": {
                "options": {
                    "validationOptions": {
                        # Kubernetes API accepts ints, in fields they annotate
                        # with string. This validation will show as warning
                        # rather than failure for Deployment Manager.
                        # kubernetes/kubernetes#2971
                        "schemaValidation": "FAIL"
                    },
                    # According to kubernetes spec, the path parameter 'name' and 'namespace'
                    # must be set inside the metadata field.
                    # https://github.com/kubernetes/community/blob/master/contributors/devel/sig-architecture/api-conventions.md#metadata
                    # The input mappings will map the values to path parameters
                    "inputMappings": [
                        {
                            "fieldName": "name",
                            "location": "PATH",
                            "methodMatch": "^(get|delete|put|patch|post)$",
                            "value": "$.resource.properties.metadata.name",
                        },
                        {
                            "fieldName": "namespace",
                            "location": "PATH",
                            "methodMatch": "^(get|delete|put|patch|post)$",
                            "value": "$.resource.properties.namespace",
                        },
                        {
                            "fieldName": "metadata.resourceVersion",
                            "location": "BODY",
                            "methodMatch": "^(put|patch)$",
                            "value": "$.resource.self.metadata.resourceVersion",
                        },
                        {
                            "fieldName": "Authorization",
                            "location": "HEADER",
                            "value": '$.concat("Bearer ",'
                            "$.googleOauth2AccessToken())",
                        },
                    ],
                },
                "collectionOverrides": [
                    {
                        "collection": "/api/v1/namespaces/{namespace}/services/{name}",
                        "options": {
                            "inputMappings": [
                                {
                                    "fieldName": "spec.clusterIP",
                                    "location": "BODY",
                                    "methodMatch": "^(put|patch)$",
                                    "value": "$.resource.self.spec.clusterIP",
                                }
                            ]
                        },
                    }
                ],
                "descriptorUrl": "https://$(ref." + base_name + ".endpoint)/openapi/v2",
            },
        },
    ]

    return {
        "resources": resources,
        "base_name": base_name,
        "kube_type_name": kube_type_name,
    }
