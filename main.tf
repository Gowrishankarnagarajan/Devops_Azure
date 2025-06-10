# This Terraform configuration sets up an Azure App Service with a resource group, app service plan, and two web apps (frontend and backend).
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

# Use the new resource type
resource "azurerm_app_service_plan" "gs" {
  name                = "azurerm_service_plan"
  location            = azurerm_resource_group.gs.location
  resource_group_name = azurerm_resource_group.gs.name
  reserved            = true 
  sku {
    tier = "Free"
    size = "F1"
  }
  kind = "Linux"
}

resource "azurerm_linux_web_app" "frontend" {
  name                = "frontend-webapp-${random_id.frontend.hex}"
  location            = azurerm_resource_group.gs.location
  resource_group_name = azurerm_resource_group.gs.name
  service_plan_id     = azurerm_app_service_plan.gs.id

  site_config {
    always_on = false
  }
} 
resource "azurerm_linux_web_app" "backend" {
  name                = "backend-webapp-${random_id.backend.hex}"
  location            = azurerm_resource_group.gs.location
  resource_group_name = azurerm_resource_group.gs.name
  service_plan_id     = azurerm_app_service_plan.gs.id

  site_config {
    always_on = false
  }
}

 
# Generate random IDs for unique web app names
# This ensures that the web app names are unique across Azure.

resource "random_id" "frontend" {
  byte_length = 4
}

resource "random_id" "backend" {
  byte_length = 4
} 