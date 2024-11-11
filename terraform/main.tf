provider "azurerm" {
  features {}
}

module "resource_group" {
  source = "./modules/resource_group"
  name   = "example-resources"
  location = "West Europe"
}

module "virtual_network" {
  source              = "./modules/virtual_network"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  vnet_name           = "example-vnet"
  address_space       = ["10.0.0.0/16"]
  subnet_name         = "example-subnet"
  subnet_prefixes     = ["10.0.1.0/24"]
}

module "container_registry" {
  source              = "./modules/container_registry"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  acr_name            = "exampleacr"
  sku                 = "Basic"
}

module "app_service" {
  source              = "./modules/app_service"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  app_service_plan_name = "example-appserviceplan"
  app_service_name    = "example-appservice"
  container_image     = "${module.container_registry.login_server}/nginx:latest"
  application_insights_key = module.application_insights.instrumentation_key
}

module "application_gateway" {
  source              = "./modules/application_gateway"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  subnet_id           = module.virtual_network.subnet_id
  public_ip_name      = "example-pip"
  app_gateway_name    = "example-appgateway"
  zones               = ["1", "2", "3"]
}

module "application_insights" {
  source              = "./modules/application_insights"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  app_insights_name   = "example-appinsights"
}