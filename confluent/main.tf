# This root creates only an identity provider and an identity pool.
# It does not create a cluster, role bindings, or ACLs.

locals {
  prefix               = var.name_prefix == "" ? "" : "${var.name_prefix}_"
  identity_provider_id = coalesce(var.identity_provider_id, one(confluent_identity_provider.entra[*].id))
}

resource "confluent_identity_provider" "entra" {
  count        = var.identity_provider_id == null ? 1 : 0
  display_name = "${local.prefix}Microsoft Entra ID - Azure UAMI"
  description  = "Entra ID provider for Azure UAMI Kafka workloads"
  issuer       = "https://login.microsoftonline.com/${var.entra_tenant_id}/v2.0"
  jwks_uri     = "https://login.microsoftonline.com/${var.entra_tenant_id}/discovery/v2.0/keys"
}

resource "confluent_identity_pool" "kafka_client" {
  display_name   = "${local.prefix}${var.identity_pool_name}"
  description    = "Identity pool for the Azure Kafka client UAMI"
  identity_claim = "claims.sub"
  filter         = "'${var.cc_claim}' in claims.roles"

  identity_provider {
    id = local.identity_provider_id
  }
}
