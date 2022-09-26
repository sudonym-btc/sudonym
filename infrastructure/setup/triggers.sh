gcloud beta builds triggers create github \
    --repo-name=sudonym \
    --repo-owner=sudonym-btc \
    --branch-pattern=$ENV \
    --build-config=/cloudbuild.yaml 
