export PROJECT_ID=$(gcloud config get project)
ENV=$1
export ENV=${ENV:="development"}
export PROJECT_NUM=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")

# bash ./apis.sh
bash ./dns.sh
# bash ./images.sh
# bash ./roles.sh
# bash ./secrets.sh
# bash ./triggers.sh