SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

DOMAIN=$ENV.sudonym.app
if [[ $ENV == "production" ]]; then
   DOMAIN=sudonym.app
fi

gcloud dns managed-zones create $ENV-zone \
   --description= \
   --dns-name=$DOMAIN \
   --visibility=public

ns=$(gcloud dns managed-zones describe $ENV-zone --format json | jq --raw-output '.nameServers  | join(" ")')

echo "Must add $ns record to production zone"
# gcloud dns record-sets transaction start \
#    --zone=production-zone

# gcloud dns record-sets transaction add $ns \
#    --name=$DOMAIN \
#    --ttl=5 \
#    --type=NS \
#    --zone=production-zone

# gcloud dns record-sets transaction execute \
#    --zone=production-zone
