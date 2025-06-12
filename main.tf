variable "prefix" {
  description = "Prefix for resource names"
  default     = "gs"
  type =  string
  
}


resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = "West Europe"
}

# Use the new resource type
resource "azurerm_service_plan" "asp" {
  name                = "azurerm_service_plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "as1" {
  name                = "${var.prefix}-webapp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.asp.id

  site_config {
     }
} 

resource "azurerm_app_service_source_control" "scm" {
  app_id            = azurerm_linux_web_app.as1.id
  branch            = "main"
  repo_url          = "https://github.com/Gowrishankarnagarajan/Invitation"
  
}
resource "azurerm_linux_web_app" "backend" {
  name                = "backend-webapp-${random_id.backend.hex}"
  location            = azurerm_resource_group.gs.location
  resource_group_name = azurerm_resource_group.gs.name
  service_plan_id     = azurerm_service_plan.gs.id

  site_config {
    always_on = false
  }
}

 
