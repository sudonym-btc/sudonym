gcloud iam service-accounts create developer \
    --description="developer" \
    --display-name="developer"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:developer@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/storage.admin"


# Cloud build account permissions
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$PROJECT_NUM@cloudbuild.gserviceaccount.com" \
    --role="roles/deploymentmanager.editor"
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$PROJECT_NUM@cloudbuild.gserviceaccount.com" \
    --role="roles/container.admin"
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$PROJECT_NUM@cloudbuild.gserviceaccount.com" \
    --role roles/iam.serviceAccountKeyAdmin

# cert-manager account for generating certificates
gcloud iam service-accounts create $ENV-solver --display-name "$ENV-solver"
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$ENV-solver@$PROJECT_ID.iam.gserviceaccount.com \
    --role roles/dns.admin