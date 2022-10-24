gcloud iam service-accounts create developer \
    --description="developer" \
    --display-name="developer"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:developer@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/storage.admin"


# Create a service account for the API and link it to Kubernetes service account
gcloud iam service-accounts create $ENV-api \
    --description="$ENV-api" \
    --display-name="$ENV-api"
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$ENV-api@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/cloudsql.client"
gcloud iam service-accounts add-iam-policy-binding \
--role="roles/iam.workloadIdentityUser" \
--member="serviceAccount:$PROJECT_ID.svc.id.goog[default/api]" \
$ENV-api@$PROJECT_ID.iam.gserviceaccount.com

# Cloud build account permissions
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$PROJECT_NUM@cloudbuild.gserviceaccount.com" \
    --role="roles/deploymentmanager.editor"
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$PROJECT_NUM@cloudbuild.gserviceaccount.com" \
    --role="roles/container.admin"
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$PROJECT_NUM@cloudbuild.gserviceaccount.com" \
    --role="roles/compute.networkViewer"
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$PROJECT_NUM@cloudbuild.gserviceaccount.com" \
    --role="roles/cloudsql.editor"
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$PROJECT_NUM@cloudbuild.gserviceaccount.com" \
    --role roles/iam.serviceAccountKeyAdmin

# cert-manager account for generating certificates
gcloud iam service-accounts create $ENV-cert-resolver --display-name "$ENV-cert-resolver"
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member serviceAccount:$ENV-cert-resolver@$PROJECT_ID.iam.gserviceaccount.com \
    --role roles/dns.admin