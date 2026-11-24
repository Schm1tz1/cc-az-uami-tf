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
