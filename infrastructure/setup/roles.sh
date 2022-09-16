gcloud iam service-accounts create developer \
    --description="developer" \
    --display-name="developer"

project=$(gcloud config get project)

gcloud projects add-iam-policy-binding $project \
    --member="serviceAccount:developer@$project.iam.gserviceaccount.com" \
    --role="roles/storage.admin"