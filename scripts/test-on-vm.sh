#!/usr/bin/env bash
# Copy test files to the VM, verify IMDS token, then produce one message with Python and one with Java.
# Needs: KAFKA_BOOTSTRAP, KAFKA_CLUSTER_ID, KAFKA_TOPIC. The pool must already be authorized for the topic.
set -euo pipefail
source "$(dirname "$0")/lib.sh"
: "${KAFKA_TOPIC:?}"
scripts/gen-env.sh

host="azureuser@$(az_out vm_public_ip)"
scp out/client.env out/client-java.properties scripts/verify-imds.sh scripts/produce.py scripts/verify-java.sh "$host":
ssh "$host" 'cloud-init status --wait >/dev/null; set -a; . ./client.env; set +a; bash verify-imds.sh && python3 produce.py && bash verify-java.sh'
