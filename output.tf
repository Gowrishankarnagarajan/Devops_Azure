# Output the web app URLs
output "frontend_web_app_url" {
  value = azurerm_linux_web_app.frontend.default_hostname
}

output "backend_web_app_url" {
  value = azurerm_linux_web_app.backend.default_hostname
}
# Output the resource group name
output "resource_group_name" {
  value = azurerm_resource_group.gs.name
} 
# Output the service plan ID
output "service_plan_id" {
  value = azurerm_service_plan.gs.id
}
# Output the location of the resource group
output "resource_group_location" {
  value = azurerm_resource_group.gs.location
}   