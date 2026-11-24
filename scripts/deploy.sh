#!/usr/bin/env bash
# Deploy Azure prerequisites, then the Confluent identity provider + pool.
# Needs: azure/terraform.tfvars, `az login`, CONFLUENT_CLOUD_API_KEY/SECRET.
set -euo pipefail
source "$(dirname "$0")/lib.sh"
: "${CONFLUENT_CLOUD_API_KEY:?}" "${CONFLUENT_CLOUD_API_SECRET:?}"
[ -f azure/terraform.tfvars ] || { echo "copy azure/terraform.tfvars.example to azure/terraform.tfvars and edit" >&2; exit 1; }

"$TF" -chdir=azure init -input=false
mkdir -p out
"$TF" -chdir=azure apply
"$TF" -chdir=azure output -json > out/azure-outputs.json

"$TF" -chdir=confluent init -input=false
"$TF" -chdir=confluent apply \
  -var "entra_tenant_id=$(az_out tenant_id)" \
  -var "entra_application_client_id=$(az_out application_client_id)" \
  -var "cc_claim=$(az_out cc_claim)"
"$TF" -chdir=confluent output -json > out/confluent-outputs.json

cat <<EOF

Pool principal: User:$(cf_out confluent_identity_pool_id)
Grant it topic (and consumer-group) access in Confluent Cloud: this repo does not.
Then: KAFKA_BOOTSTRAP=... KAFKA_CLUSTER_ID=lkc-... KAFKA_TOPIC=... scripts/test-on-vm.sh
EOF
