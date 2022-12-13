export PROJECT_ID=$(gcloud config get project)
ENV=$1
export ENV=${ENV:="development"}
export PROJECT_NUM=$(gcloud projects describe $PROJECT_ID --format="value(projectNumber)")
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

echo "Setting up..."

# bash $SCRIPT_DIR/apis.sh
# bash $SCRIPT_DIR/dns.sh
bash $SCRIPT_DIR/images.sh
bash $SCRIPT_DIR/roles.sh
bash $SCRIPT_DIR/secrets.sh
bash $SCRIPT_DIR/triggers.sh
