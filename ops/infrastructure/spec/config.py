
def GenerateConfig(context):

    resources = [
        {
            "name": "kubernetes",
            "type": "kubernetes.py",
            "properties": context.properties
        }
    ]
    return {"resources": resources}
