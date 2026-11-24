output "tenant_id" {
  description = "Entra tenant ID."
  value       = data.azuread_client_config.current.tenant_id
}

output "application_client_id" {
  description = "Application (client) ID. Used in the Confluent pool filter (token aud)."
  value       = azuread_application.cc_audience.client_id
}

output "application_id_uri" {
  description = "Application ID URI. Used as the IMDS resource."
  value       = var.application_id_uri
}

output "cc_claim" {
  description = "Value in the token roles claim (app role value). Used in the Confluent pool filter."
  value       = var.cc_claim
}

output "uami_client_id" {
  description = "UAMI client ID. Used as the IMDS client_id."
  value       = azurerm_user_assigned_identity.kafka_client.client_id
}

output "uami_principal_id" {
  description = "UAMI service principal object ID."
  value       = azurerm_user_assigned_identity.kafka_client.principal_id
}

output "uami_id" {
  description = "UAMI resource ID. Use it to attach the UAMI to your own workload."
  value       = azurerm_user_assigned_identity.kafka_client.id
}

output "vm_public_ip" {
  description = "Public IP of the test VM. Null when create_vm is false."
  value       = one(azurerm_public_ip.vm[*].ip_address)
}
