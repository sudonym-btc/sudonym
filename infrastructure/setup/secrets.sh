# Create service account secret for DNS certificate cert-manager
(gcloud secrets describe $ENV-cert-resolver >/dev/null 2>&1 && echo "already got secret" ||
    (gcloud iam service-accounts keys create key.json \
        --iam-account $ENV-cert-resolver@$PROJECT_ID.iam.gserviceaccount.com &&
        gcloud secrets create $ENV-cert-resolver --data-file=key.json))

gcloud secrets add-iam-policy-binding $ENV-cert-resolver \
    --member="serviceAccount:$PROJECT_NUM@cloudbuild.gserviceaccount.com" \
    --role=roles/secretmanager.secretAccessor