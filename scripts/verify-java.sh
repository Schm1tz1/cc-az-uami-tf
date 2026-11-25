#!/usr/bin/env bash
# Run ON the Azure workload. Produce one message with the Confluent console producer (Java).
# Needs client.env and client-java.properties in the current directory (from gen-env.sh),
# and the Confluent Community tarball in /opt (installed by cloud-init).
set -euo pipefail
. ./client.env

cp=/opt/confluent-8.1.0
# UamiJwtRetriever lives in kafka-client-plugins. Add it to the CLI classpath.
export CLASSPATH=$cp/share/java/ksqldb/kafka-client-plugins-8.1.0-ce.jar
export KAFKA_OPTS="-Dorg.apache.kafka.sasl.oauthbearer.allowed.urls=$IMDS_URL"

echo "java-client-test:UAMI OAuth test with Java Console Producer" | "$cp/bin/kafka-console-producer" \
  --property parse.key=true --property key.separator=: \
  --bootstrap-server "$KAFKA_BOOTSTRAP" --topic "$KAFKA_TOPIC" \
  --producer.config client-java.properties
echo "java: message sent"
