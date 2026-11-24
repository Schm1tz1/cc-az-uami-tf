terraform {
  required_version = ">= 1.5.0"

  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = ">= 2.66.0"
    }
  }
}

# Credentials come from CONFLUENT_CLOUD_API_KEY and CONFLUENT_CLOUD_API_SECRET.
provider "confluent" {}
