project=$(gcloud config get project)

helm repo add jetstack https://charts.jetstack.io
helm repo update
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.7.1/cert-manager.crds.yaml
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.7.1 
gcloud container clusters get-credentials test-cluster --zone us-central1-c --project sudonym-lightning-test

kubectl apply -f infrastructure/ssl/certs.yaml
