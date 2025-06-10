terraform { 
  cloud { 
    organization = "gs-devops" 
    workspaces { 
      name = "Devops" 
    } 
  } 
}

resource "azurerm_resource_group" "gs" {
  name     = "example-webapp-rg"
  location = "West Europe"
}

resource "azurerm_service_plan" "gs" {
  name                = "azurerm_service_plan"
  location            = azurerm_resource_group.gs.location
  resource_group_name = azurerm_resource_group.gs.name
  sku_name            = "F1"
  os_type             = "Linux"
}

resource "azurerm_linux_web_app" "frontend" {
  name                = "frontend-webapp-${random_id.frontend.hex}"
  location            = azurerm_resource_group.gs.location
  resource_group_name = azurerm_resource_group.gs.name
  service_plan_id     = azurerm_service_plan.gs.id

  site_config {}

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
  }

  source_control {
    repo_url           = "https://github.com/Gowrishankarnagarajan/Invitation.git"
    branch             = "main"
    manual_integration = true
  }
}

resource "azurerm_linux_web_app" "backend" {
  name                = "backend-webapp-${random_id.backend.hex}"
  location            = azurerm_resource_group.gs.location
  resource_group_name = azurerm_resource_group.gs.name
  service_plan_id     = azurerm_service_plan.gs.id

  site_config {}
}

resource "random_id" "frontend" {
  byte_length = 4
}

resource "random_id" "backend" {
  byte_length = 4
}