resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = "UK South"
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
  name                = "${var.prefix}-webapp1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.asp.id
  depends_on = [ azurerm_resource_group.rg,azurerm_service_plan.asp ]
  site_config {

    always_on = false

     }
} 

resource "azurerm_app_service_source_control" "scm" {
  app_id            = azurerm_linux_web_app.as1.id
  branch            = "main"
  repo_url          = "https://github.com/Gowrishankarnagarajan/Invitation"
  depends_on = [ azurerm_linux_web_app.as1 ]
}
resource "azurerm_linux_web_app" "as2" {
  name                = "${var.prefix}-webapp2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.asp.id
  depends_on = [ azurerm_resource_group.rg,azurerm_service_plan.asp ]
  site_config {
    always_on = false
  }
}

 
