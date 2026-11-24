#!/usr/bin/env bash
# Run ON the Azure workload. Request a token from IMDS and print its iss/aud/sub/roles/exp.
# Needs client.env in the current directory (from gen-env.sh), curl, and jq.
set -euo pipefail
. ./client.env

token=$(curl --fail --silent --show-error -H 'Metadata: true' \
  --get 'http://169.254.169.254/metadata/identity/oauth2/token' \
  --data-urlencode 'api-version=2025-04-07' \
  --data-urlencode "resource=${APP_ID_URI}" \
  --data-urlencode "client_id=${UAMI_CLIENT_ID}" | jq -r .access_token)

# Decode the claims locally. Never print the token.
jq -R 'split(".")[1] | gsub("-";"+") | gsub("_";"/") | @base64d | fromjson | {iss, aud, sub, roles, exp}' <<<"$token"
