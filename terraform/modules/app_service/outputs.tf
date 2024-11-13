output "app_service_name" {
  value = azurerm_linux_web_app.this.id
}

output "default_site_hostname" {
  value = azurerm_linux_web_app.this.default_hostname
}