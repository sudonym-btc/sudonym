#!/bin/bash
export PROJECT_ID=$(gcloud config get project)
ENV=$1
export ENV=${ENV:="development"}
export PROJECT_NUM=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")

if [ "$1" != "development" ];
then
    echo "$1"

    # Convert Google secrets to kubernetes secrets
    gcloud container clusters get-credentials --zone "us-central1-c" "$1-cluster"
    gcloud secrets versions access latest --secret="$1-cert-resolver" --out-file="key.json"  
    kubectl create secret generic $1-cert-resolver --from-file=key.json
    rm key.json 
    gcloud secrets versions access latest --secret="$1-ride-the-lightning-secret" --out-file="key.txt"  
    kubectl create secret generic $1-ride-the-lightning-secret --from-file=key.txt
    rm key.txt

    kubectl annotate serviceaccount --overwrite api iam.gke.io/gcp-service-account=$ENV-api@$PROJECT_ID.iam.gserviceaccount.com

    helm repo add jetstack https://charts.jetstack.io
    helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    helm repo update
    
    loadBalancerIP=$(gcloud compute addresses describe $1-ip --region=us-central1 --format='get(address)')
    echo "Setting load balancer IP $loadBalancerIP"
    helm upgrade --install nginx-ingress ingress-nginx/ingress-nginx --set controller.service.loadBalancerIP=$loadBalancerIP
    helm upgrade --install \
            cert-manager jetstack/cert-manager \
            --namespace cert-manager \
            --create-namespace \
            --version v1.7.1 \
            --set installCRDs=true

    pip3 install -r infrastructure/minikube/requirements.txt
    python3 infrastructure/spec/certificates.py $1 | kubectl apply -f -
fi