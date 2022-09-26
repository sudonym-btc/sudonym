#!/bin/bash

if [ "$1" != "development" ];
then
    echo "$1"
    gcloud container clusters get-credentials --zone "us-central1-c" "$1-cluster"
    gcloud secrets versions access latest --secret="$1-cert-resolver" --out-file="key.json"  
    kubectl create secret generic $1-cert-resolver --from-file=key.json
    rm key.json 

    helm repo add jetstack https://charts.jetstack.io
    help repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
    helm repo update
    helm upgrade --install nginx-ingress ingress-nginx/ingress-nginx --set controller.service.loadBalancerIP=$(gcloud compute addresses describe $1-ip --region=us-central1 --format='get(address)')
    helm upgrade --install \
            cert-manager jetstack/cert-manager \
            --namespace cert-manager \
            --create-namespace \
            --version v1.7.1 \
            --set installCRDs=true

    python3 -m ensurepip --upgrade
    pip3 install -r infrastructure/minikube/requirements.txt
    python3 infrastructure/spec/certificates.py $1 | kubectl apply -f -
fi