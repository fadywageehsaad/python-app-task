resource "azurerm_app_service_plan" "this" {
  name                = var.app_service_plan_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku {
    tier = "Standard"
    size = "S1"
  }
  zone_redundant = false
}

resource "azurerm_app_service" "this" {
  name                = var.app_service_name
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.this.id

  site_config {
    python_version   = "3.4"
    app_command_line = ""
  }

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"  = var.application_insights_key
    "DOCKER_REGISTRY_SERVER_URL"      = "https://${var.container_registry_login_server}"
    "DOCKER_REGISTRY_SERVER_USERNAME" = var.container_registry_username
    "DOCKER_REGISTRY_SERVER_PASSWORD" = var.container_registry_password
  }
}