gcloud iam service-accounts create developer \
    --description="developer" \
    --display-name="developer"

project=$(gcloud config get project)

gcloud projects add-iam-policy-binding $project \
    --member="serviceAccount:developer@$project.iam.gserviceaccount.com" \
    --role="roles/storage.admin"

project_num=$(gcloud projects describe $(gcloud config get project) --format="value(projectNumber)")

gcloud projects add-iam-policy-binding $project \
    --member="serviceAccount:$project_num@cloudbuild.gserviceaccount.com" \
    --role="roles/deploymentmanager.editor"