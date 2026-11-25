"""Smoke-test producer using Azure IMDS OAuth. Reads client.env values from the environment."""
import os
import sys
from urllib.parse import quote

from confluent_kafka import Producer

e = os.environ
query = (
    "query=api-version=2025-04-07"
    f"&resource={quote(e['APP_ID_URI'], safe='')}"
    f"&client_id={e['UAMI_CLIENT_ID']}"
)
failed = []


def on_delivery(err, msg):
    if err:
        failed.append(err)
        print(f"delivery failed: {err}", file=sys.stderr)
    else:
        print(f"delivered to {msg.topic()}[{msg.partition()}]@{msg.offset()}")


p = Producer({
    "bootstrap.servers": e["KAFKA_BOOTSTRAP"],
    "security.protocol": "SASL_SSL",
    "sasl.mechanisms": "OAUTHBEARER",
    "sasl.oauthbearer.method": "oidc",
    "sasl.oauthbearer.metadata.authentication.type": "azure_imds",
    "sasl.oauthbearer.config": query,
    "sasl.oauthbearer.extensions": f"logicalCluster={e['KAFKA_CLUSTER_ID']},identityPoolId={e['IDENTITY_POOL_ID']}",
    "error_cb": lambda err: print(f"kafka error: {err}", file=sys.stderr),
})
p.produce(e["KAFKA_TOPIC"], key="python-client-test", value="UAMI OAuth test with Python Producer from confluent_kafka", on_delivery=on_delivery)
if p.flush(30) or failed:
    sys.exit("produce failed (auth ok but denied? check pool authorization)")
