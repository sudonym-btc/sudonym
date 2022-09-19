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

gcloud projects add-iam-policy-binding $project \
    --member="serviceAccount:$project_num@cloudbuild.gserviceaccount.com" \
    --role="roles/container.admin"

gcloud iam service-accounts create dns01-solver --display-name "dns01-solver"
gcloud projects add-iam-policy-binding $project \
    --member serviceAccount:dns01-solver@$project.iam.gserviceaccount.com \
    --role roles/dns.admin

gcloud iam service-accounts keys create key.json \
   --iam-account dns01-solver@$project.iam.gserviceaccount.com
kubectl create secret generic clouddns-dns01-solver-svc-acct \
   --from-file=key.json