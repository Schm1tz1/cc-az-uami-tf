variable "entra_tenant_id" {
  description = "Microsoft Entra tenant ID."
  type        = string
}

variable "cc_claim" {
  description = "Value that must be in the token roles claim. The pool filter requires it."
  type        = string
}

variable "identity_pool_name" {
  description = "Display name of the identity pool."
  type        = string
  default     = "azure-kafka-client"
}

variable "identity_provider_id" {
  description = "ID of an existing identity provider for this tenant (op-...). If null, the root creates one. Confluent allows one provider for each issuer in an organization."
  type        = string
  default     = null
}

variable "name_prefix" {
  description = "Optional prefix for the display names of the resources this root creates. The name becomes <prefix>_<name>."
  type        = string
  default     = ""
}
