provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "gs" {
  name     = "example-webapp-rg"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "gs" {
  name                = "example-appserviceplan"
  location            = azurerm_resource_group.gs.location
  resource_group_name = azurerm_resource_group.gs.name
  kind                = "Linux"   # Use Linux for the App Service Plan    

  sku {
    tier = "Free"
    size = "F1"
  }
}

resource "azurerm_app_service" "frontend" {
    name                = "frontend-webapp-${random_id.frontend.hex}"
    location            = azurerm_resource_group.gs.location
    resource_group_name = azurerm_resource_group.gs.name
    app_service_plan_id = azurerm_app_service_plan.gs.id

    site_config {
        scm_type = "GitHub"
    }

    app_settings = {
        "WEBSITE_RUN_FROM_PACKAGE" = "1"
    }

    source_control {
        repo_url           = "https://github.com/Gowrishankarnagarajan/Invitation.git"
        branch             = "main"
        manual_integration = true
    }
}

resource "azurerm_app_service" "backend" {
  name                = "backend-webapp-${random_id.backend.hex}"
  location            = azurerm_resource_group.gs.location
  resource_group_name = azurerm_resource_group.gs.name
  app_service_plan_id = azurerm_app_service_plan.gs.id
  
}

resource "random_id" "frontend" {
  byte_length = 4
}

resource "random_id" "backend" {
  byte_length = 4
}