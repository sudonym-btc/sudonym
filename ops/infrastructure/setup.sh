gcloud services enable deploymentmanager.googleapis.com &&
gcloud services enable cloudbuild.googleapis.com &&
gcloud services enable container.googleapis.com &&
gcloud services enable storage.googleapis.com
gcloud services enable dns.googleapis.com
gcloud beta builds triggers create github \
    --repo-name=sudonym \
    --repo-owner=sudonym-btc \
    --branch-pattern=main \
    --build-config=/cloudbuild.yaml \
    --require-approval