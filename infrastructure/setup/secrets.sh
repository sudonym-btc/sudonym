# Create service account secret for DNS certificate cert-manager
(gcloud secrets describe $ENV-cert-resolver >/dev/null 2>&1 && echo "already got secret") ||
    (gcloud iam service-accounts keys create key.json \
        --iam-account $ENV-cert-resolver@$PROJECT_ID.iam.gserviceaccount.com &&
        gcloud secrets create $ENV-cert-resolver --data-file=key.json && rm key.json)

gcloud secrets add-iam-policy-binding $ENV-cert-resolver \
    --member="serviceAccount:$PROJECT_NUM@cloudbuild.gserviceaccount.com" \
    --role=roles/secretmanager.secretAccessor

# Create service account secret for lightning backup
(gcloud secrets describe $ENV-lightning-service-account >/dev/null 2>&1 && echo "already got secret") ||
    (gcloud iam service-accounts keys create key.json \
        --iam-account $ENV-lightning@$PROJECT_ID.iam.gserviceaccount.com &&
        gcloud secrets create $ENV-lightning-service-account --data-file=key.json && rm key.json)

# Create a random password for RTL lightning node admin if it does not yet exist
openssl rand -hex 16 | tr -d '\n' | gcloud secrets create $ENV-ride-the-lightning-secret --data-file=-
# Cloud build needs access to write secret to config file
gcloud secrets add-iam-policy-binding $ENV-ride-the-lightning-secret \
    --member="serviceAccount:$PROJECT_NUM@cloudbuild.gserviceaccount.com" \
    --role=roles/secretmanager.secretAccessor

# Create a random password for database if it does not yet exist
openssl rand -hex 16 | tr -d '\n' | gcloud secrets create $ENV-db-secret --data-file=-
# Cloud build needs access to write secret to config file
gcloud secrets add-iam-policy-binding $ENV-db-secret \
    --member="serviceAccount:$PROJECT_NUM@cloudbuild.gserviceaccount.com" \
    --role=roles/secretmanager.secretAccessor
