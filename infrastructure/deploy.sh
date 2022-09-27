
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# Checks if the deployment already exists, then updates it or creates one

if gcloud deployment-manager deployments describe deploy-$1 >/dev/null 2>&1; then
    cmd="gcloud deployment-manager deployments update deploy-$1 --config=infrastructure/spec/config-$1.yaml"
else
    cmd="gcloud deployment-manager deployments create deploy-$1 --config=infrastructure/spec/config-$1.yaml"
fi

eval $cmd && bash $SCRIPT_DIR/post-deploy.sh $1