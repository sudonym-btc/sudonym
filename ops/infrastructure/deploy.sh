# Checks if the deployment already exists, then updates it or creates one

if gcloud deployment-manager deployments describe deploy-$1 >/dev/null 2>&1; then
    gcloud deployment-manager deployments update deploy-$1 --config=ops/infrastructure/config-$1.yaml
else
    gcloud deployment-manager deployments create deploy-$1 --config=ops/infrastructure/config-$1.yaml
fi