#!/usr/bin/env bash
# Copy test files to the VM, verify IMDS token, then produce one message.
# Needs: KAFKA_BOOTSTRAP, KAFKA_CLUSTER_ID, KAFKA_TOPIC. The pool must already be authorized for the topic.
set -euo pipefail
source "$(dirname "$0")/lib.sh"
: "${KAFKA_TOPIC:?}"
scripts/gen-env.sh

host="azureuser@$(az_out vm_public_ip)"
scp out/client.env scripts/verify-imds.sh scripts/produce.py "$host":
ssh "$host" 'cloud-init status --wait >/dev/null; set -a; . ./client.env; set +a; bash verify-imds.sh && python3 produce.py'
