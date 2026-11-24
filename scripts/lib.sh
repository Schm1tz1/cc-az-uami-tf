# Sourced by the other scripts. Runs from repo root; picks tofu, else terraform.
cd "$(dirname "${BASH_SOURCE[0]}")/.."
if [ -f .env ]; then set -a; . ./.env; set +a; fi
TF=$(command -v tofu || command -v terraform) || { echo "need tofu or terraform" >&2; exit 1; }
az_out() { "$TF" -chdir=azure output -raw "$1"; }
cf_out() { "$TF" -chdir=confluent output -raw "$1"; }
