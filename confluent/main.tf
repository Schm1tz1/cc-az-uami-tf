# This root creates only an identity provider and an identity pool.
# It does not create a cluster, role bindings, or ACLs.

resource "confluent_identity_provider" "entra" {
  display_name = "Microsoft Entra ID - Azure UAMI"
  description  = "Entra ID provider for Azure UAMI Kafka workloads"
  issuer       = "https://login.microsoftonline.com/${var.entra_tenant_id}/v2.0"
  jwks_uri     = "https://login.microsoftonline.com/${var.entra_tenant_id}/discovery/v2.0/keys"
}

resource "confluent_identity_pool" "kafka_client" {
  display_name   = var.identity_pool_name
  description    = "Identity pool for the Azure Kafka client UAMI"
  identity_claim = "claims.sub"
  filter         = "claims.aud == \"${var.entra_application_client_id}\" && '${var.cc_claim}' in claims.roles"

  identity_provider {
    id = confluent_identity_provider.entra.id
  }
}
