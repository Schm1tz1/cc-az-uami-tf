variable "subscription_id" {
  description = "Azure subscription ID. If null, ARM_SUBSCRIPTION_ID is used."
  type        = string
  default     = null
}

variable "owner" {
  description = "Owner user name. Set as the owner tag on Azure resources and in the Entra app name and notes."
  type        = string
}

variable "owner_email" {
  description = "Owner email address. Set as the owner_email tag and in the Entra app notes."
  type        = string
}

variable "cc_claim" {
  description = "Value for the token roles claim. Created as an Entra app role and assigned to the UAMI. The identity pool filter requires it."
  type        = string
  default     = "cc-kafka-clients"
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "westeurope"
}

variable "resource_group_name" {
  description = "Name of the resource group to create."
  type        = string
}

variable "application_id_uri" {
  description = "Application ID URI of the Entra app. The client sends it as the IMDS resource. Confluent recommends api://<bootstrap-host>:9092."
  type        = string
}

variable "uami_name" {
  description = "Name of the user-assigned managed identity."
  type        = string
  default     = "cc-kafka-client-uami"
}

variable "create_vm" {
  description = "Create a test VM with the UAMI attached. Set to false to attach the UAMI to your own workload."
  type        = bool
  default     = true
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key for the test VM."
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to open SSH to the test VM, for example 203.0.113.4/32. Required when create_vm is true."
  type        = string
  default     = ""
}
