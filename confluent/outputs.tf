output "confluent_identity_provider_id" {
  description = "ID of the OAuth/OIDC identity provider."
  value       = confluent_identity_provider.entra.id
}

output "confluent_identity_pool_id" {
  description = "ID of the identity pool. The Kafka principal is User:<this ID>."
  value       = confluent_identity_pool.kafka_client.id
}
