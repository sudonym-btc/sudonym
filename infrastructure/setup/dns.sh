project=$(gcloud config get project)
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

gcloud dns managed-zones create main-zone \
    --description=sudonym.app \
    --dns-name=sudonym.app \
    --visibility=public

gcloud dns record-sets import $SCRIPT_DIR/app-records.yaml --delete-all-existing --zone=main-zone
