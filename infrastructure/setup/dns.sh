SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

gcloud dns managed-zones create $ENV-zone \
    --description=$ENV.sudonym.app \
    --dns-name=$ENV.sudonym.app \
    --visibility=public

gcloud dns managed-zones create main-zone \
    --description=sudonym.app \
    --dns-name=sudonym.app \
    --visibility=public

ns=$(gcloud dns managed-zones describe test-zone --format json | jq --raw-output '.nameServers  | join(" ")')

gcloud dns record-sets transaction start \
   --zone=main-zone

gcloud dns record-sets transaction add $ns \
   --name=$ENV.sudonym.app \
   --ttl=5 \
   --type=NS \
   --zone=main-zone

gcloud dns record-sets transaction execute \
   --zone=main-zone