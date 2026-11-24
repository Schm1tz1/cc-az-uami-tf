#!/usr/bin/env bash
# Write client settings from tofu outputs into out/:
#   client.env              used by produce.py / verify-imds.sh
#   client-java.properties  Java client (also needs the -D flag printed below)
# Needs: KAFKA_BOOTSTRAP, KAFKA_CLUSTER_ID. jq locally.
set -euo pipefail
source "$(dirname "$0")/lib.sh"
: "${KAFKA_BOOTSTRAP:?host:9092}" "${KAFKA_CLUSTER_ID:?lkc-...}"

uri=$(az_out application_id_uri); uami=$(az_out uami_client_id); pool=$(cf_out confluent_identity_pool_id)
mkdir -p out

{
  printf 'KAFKA_BOOTSTRAP=%q\n' "$KAFKA_BOOTSTRAP"
  printf 'KAFKA_CLUSTER_ID=%q\n' "$KAFKA_CLUSTER_ID"
  printf 'KAFKA_TOPIC=%q\n' "${KAFKA_TOPIC:-}"
  printf 'APP_ID_URI=%q\n' "$uri"
  printf 'UAMI_CLIENT_ID=%q\n' "$uami"
  printf 'IDENTITY_POOL_ID=%q\n' "$pool"
} > out/client.env

imds="http://169.254.169.254/metadata/identity/oauth2/token?api-version=2025-04-07&resource=$(jq -rn --arg u "$uri" '$u|@uri')&client_id=$uami"
cat > out/client-java.properties <<EOF
# Run the JVM with:
#   -Dorg.apache.kafka.sasl.oauthbearer.allowed.urls=$imds
# Needs io.confluent:kafka-client-plugins >= 8.1 on the classpath.
bootstrap.servers=$KAFKA_BOOTSTRAP
security.protocol=SASL_SSL
sasl.mechanism=OAUTHBEARER
sasl.oauthbearer.jwt.retriever.class=io.confluent.security.auth.client.oauth.UamiJwtRetriever
sasl.oauthbearer.token.endpoint.url=$imds
sasl.jaas.config=org.apache.kafka.common.security.oauthbearer.OAuthBearerLoginModule required extension_logicalCluster="$KAFKA_CLUSTER_ID" extension_identityPoolId="$pool";
EOF
echo "wrote out/client.env out/client-java.properties"
