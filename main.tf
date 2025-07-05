terraform {
  required_providers {
    azurerm = { source = "hashicorp/azurerm" version = "~>3.0" }
    random  = { source = "hashicorp/random" version = "~>3.0" }
  }
}

provider "azurerm" {
  features {}
}

# 🎯 Variables
variable "prefix" {
  type    = string
  default = "sample"
}

# 1. Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = "UK South"
}

resource "random_id" "suffix" {
  byte_length = 4
}

# 2. Storage Account + Container for deployment ZIP
resource "azurerm_storage_account" "sa" {
  name                     = "${var.prefix}sa${random_id.suffix.hex}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  account_kind             = "StorageV2"
}

resource "azurerm_storage_container" "deploy" {
  name                  = "deploy"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

resource "azurerm_storage_blob" "appzip" {
  name                   = "app_${random_id.suffix.hex}.zip"
  storage_account_name   = azurerm_storage_account.sa.name
  storage_container_name = azurerm_storage_container.deploy.name
  type                   = "Block"
  source                 = "${path.module}/app_build/app.zip"
}

# 3. App Service Plan
resource "azurerm_service_plan" "asp" {
  name                = "${var.prefix}-asp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "B1"
}

# 4. Linux Web App
resource "azurerm_linux_web_app" "app" {
  name                = "${var.prefix}-webapp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.asp.id
  https_only          = true

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      node_version = "16-lts"
    }
  }

  app_settings = {
    # Tell App Service to mount and run from the ZIP in storage
    WEBSITE_RUN_FROM_PACKAGE = azurerm_storage_blob.appzip.url
  }
}

# 5. Grant Web App permission to read the package
resource "azurerm_role_assignment" "webapp_storage_read" {
  principal_id         = azurerm_linux_web_app.app.identity[0].principal_id
  role_definition_name = "Storage Blob Data Reader"
  scope                = azurerm_storage_blob.appzip.id
}

# 🛠 Outputs
output "webapp_url" {
  value = azurerm_linux_web_app.app.default_hostname
}
