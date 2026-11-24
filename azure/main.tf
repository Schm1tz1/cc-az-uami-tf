data "azuread_client_config" "current" {}

locals {
  vm = var.create_vm ? 1 : 0

  # Azure resource tags and Entra tags.
  tags     = { owner = var.owner, owner_email = var.owner_email }
  app_tags = ["owner:${var.owner}", "owner_email:${var.owner_email}"]

  # Stable app role ID. Same inputs give the same ID on every run.
  cc_claim_role_id = uuidv5("url", "${var.application_id_uri}/${var.cc_claim}")
}

# ---- Identity ---------------------------------------------------------------

resource "azurerm_resource_group" "identity" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.tags
}

resource "azurerm_user_assigned_identity" "kafka_client" {
  name                = var.uami_name
  resource_group_name = azurerm_resource_group.identity.name
  location            = azurerm_resource_group.identity.location
  tags                = local.tags
}

resource "azuread_application" "cc_audience" {
  display_name    = "Confluent Cloud Kafka workload (${var.owner})"
  owners          = [data.azuread_client_config.current.object_id]
  identifier_uris = [var.application_id_uri]
  notes           = "Owner: ${var.owner} <${var.owner_email}>"
  tags            = local.app_tags

  # The role value appears in the token roles claim. The identity pool filter uses it.
  app_role {
    allowed_member_types = ["Application"]
    description          = "Confluent Cloud Kafka client"
    display_name         = var.cc_claim
    enabled              = true
    id                   = local.cc_claim_role_id
    value                = var.cc_claim
  }

  api {
    requested_access_token_version = 2
  }
}

resource "azuread_service_principal" "cc_audience" {
  client_id = azuread_application.cc_audience.client_id
  owners    = [data.azuread_client_config.current.object_id]
  notes     = "Owner: ${var.owner} <${var.owner_email}>"
  tags      = local.app_tags
}

# Assign the app role to the UAMI service principal.
resource "azuread_app_role_assignment" "kafka_client" {
  app_role_id         = local.cc_claim_role_id
  principal_object_id = azurerm_user_assigned_identity.kafka_client.principal_id
  resource_object_id  = azuread_service_principal.cc_audience.object_id
}

# ---- Optional test VM -------------------------------------------------------

resource "azurerm_virtual_network" "vm" {
  count               = local.vm
  name                = "kafka-client-vnet"
  address_space       = ["10.20.0.0/16"]
  location            = azurerm_resource_group.identity.location
  resource_group_name = azurerm_resource_group.identity.name
  tags                = local.tags
}

resource "azurerm_subnet" "vm" {
  count                = local.vm
  name                 = "default"
  resource_group_name  = azurerm_resource_group.identity.name
  virtual_network_name = azurerm_virtual_network.vm[0].name
  address_prefixes     = ["10.20.1.0/24"]
}

resource "azurerm_network_security_group" "vm" {
  count               = local.vm
  name                = "kafka-client-nsg"
  location            = azurerm_resource_group.identity.location
  resource_group_name = azurerm_resource_group.identity.name
  tags                = local.tags

  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.allowed_ssh_cidr
    destination_address_prefix = "*"
  }

  lifecycle {
    precondition {
      condition     = var.allowed_ssh_cidr != ""
      error_message = "Set allowed_ssh_cidr (your public IP /32) when create_vm = true."
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "vm" {
  count                     = local.vm
  subnet_id                 = azurerm_subnet.vm[0].id
  network_security_group_id = azurerm_network_security_group.vm[0].id
}

resource "azurerm_public_ip" "vm" {
  count               = local.vm
  name                = "kafka-client-pip"
  location            = azurerm_resource_group.identity.location
  resource_group_name = azurerm_resource_group.identity.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

resource "azurerm_network_interface" "vm" {
  count               = local.vm
  name                = "kafka-client-nic"
  location            = azurerm_resource_group.identity.location
  resource_group_name = azurerm_resource_group.identity.name
  tags                = local.tags

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.vm[0].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm[0].id
  }
}

resource "azurerm_linux_virtual_machine" "client" {
  count                 = local.vm
  name                  = "kafka-client"
  location              = azurerm_resource_group.identity.location
  resource_group_name   = azurerm_resource_group.identity.name
  size                  = "Standard_B1s"
  admin_username        = "azureuser"
  network_interface_ids = [azurerm_network_interface.vm[0].id]
  custom_data           = base64encode(file("${path.module}/cloud-init.yaml"))
  tags                  = local.tags

  admin_ssh_key {
    username   = "azureuser"
    public_key = file(pathexpand(var.ssh_public_key_path))
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.kafka_client.id]
  }
}
