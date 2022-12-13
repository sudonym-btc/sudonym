SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

gcloud beta builds triggers create github \
    --name="$ENV-trigger" \
    --repo-name=sudonym \
    --repo-owner=sudonym-btc \
    --branch-pattern=$ENV \
    --build-config=$SCRIPT_DIR/cloudbuild.yaml \
    --included-files=api/**,models/**,app/**
