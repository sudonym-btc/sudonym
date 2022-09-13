# gcloud services enable deploymentmanager.googleapis.com &&
# gcloud services enable cloudbuild.googleapis.com &&
# gcloud services enable container.googleapis.com &&
# gcloud services enable storage.googleapis.com
# gcloud services enable dns.googleapis.com
# gcloud services enable androidpublisher.googleapis.com
# gcloud beta builds triggers create github \
#     --repo-name=sudonym \
#     --repo-owner=sudonym-btc \
#     --branch-pattern=main \
#     --build-config=/cloudbuild.yaml \
#     --require-approval
helm repo add jetstack https://charts.jetstack.io
helm repo update
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.7.1/cert-manager.crds.yaml
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.7.1 
kubectl apply -f ops/infrastructure/ssl/certs.yaml --cluster gke_sudonym-lightning-test_us-central1-c_staging-cluster

# gcloud builds submit ops/cloud-builders-community/fastlane --config=ops/cloud-builders-community/fastlane/cloudbuild.yaml
# gcloud builds submit ops/cloud-builders-community/flutter --config=ops/cloud-builders-community/flutter/cloudbuild.yaml