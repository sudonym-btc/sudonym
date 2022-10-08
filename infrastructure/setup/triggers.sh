gcloud beta builds triggers create github \
    --name="$ENV-trigger" \
    --repo-name=sudonym \
    --repo-owner=sudonym-btc \
    --branch-pattern=$ENV \
    --build-config=/cloudbuild.yaml \
    --included-files=api/** \
    --included-files=models/**