#!/usr/bin/env bash
# Destroy Confluent identity resources first, then Azure.
set -euo pipefail
source "$(dirname "$0")/lib.sh"
: "${CONFLUENT_CLOUD_API_KEY:?}" "${CONFLUENT_CLOUD_API_SECRET:?}"

"$TF" -chdir=confluent destroy \
  -var "entra_tenant_id=$(az_out tenant_id)" \
  -var "cc_claim=$(az_out cc_claim)"
"$TF" -chdir=azure destroy
