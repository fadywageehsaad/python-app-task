resource "azurerm_service_plan" "this" {
  name                = var.app_service_plan_name
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = "S1"
}

resource "azurerm_linux_web_app" "this" {
  name                = var.app_service_name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.this.id

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
    "APPINSIGHTS_INSTRUMENTATIONKEY"  = var.application_insights_key
  }

  site_config {
    application_stack {
      docker_image_name        = var.docker_image_name
      docker_registry_url      = "https://${var.container_registry_login_server}"
      docker_registry_username = var.container_registry_username
      docker_registry_password = var.container_registry_password
    }
  }
}