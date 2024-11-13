provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = "0b89156f-39fb-4b31-9fdb-254d4eeca0a7"
}

module "resource_group" {
  source = "./modules/resource_group"
  name   = "python-application-resources"
  location = "West Europe"
}

module "virtual_network" {
  source              = "./modules/virtual_network"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  vnet_name           = "python-application-vnet"
  address_space       = ["10.0.0.0/16"]
  subnets = [
    {
      subnet_name       = "example-subnet-1"
      subnet_prefix     = "10.0.1.0/24"
      private_endpoint_network_policies = "Disabled"
      private_link_service_network_policies_enabled = false
      
    },
    {
      subnet_name                       = "example-subnet-3"
      subnet_prefix                     = "10.0.2.0/24"
      private_endpoint_network_policies = "Disabled"
      private_link_service_network_policies_enabled = false
    }
  ]
}

module "container_registry" {
  source              = "./modules/container_registry"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  acr_name            = "pythonapplicationtest"
  sku                 = "Basic"
}

module "app_service" {
  source                                  = "./modules/app_service"
  resource_group_name                     = module.resource_group.name
  location                                = module.resource_group.location
  app_service_plan_name                   = "python-application-appserviceplan2"
  app_service_name                        = "exapython-appliaction-mple-appservice"
  container_image                         = "${module.container_registry.login_server}/nginx:latest"
  application_insights_key                = module.application_insights.instrumentation_key
  container_registry_login_server         = module.container_registry.login_server
  container_registry_username             = module.container_registry.admin_username
  container_registry_password             = module.container_registry.admin_password
  docker_image_name                       = "exapython-appliaction-mple-appservice:latest"
  connection_string                       = module.application_insights.connection_string
  container_registry_use_managed_identity = true
  private_endpoint_subnet_id              = module.virtual_network.subnets[1]
}

module "application_gateway" {
  source                  = "./modules/application_gateway"
  resource_group_name     = module.resource_group.name
  location                = module.resource_group.location
  app_gateway_subnet_id   = module.virtual_network.subnets[0]
  public_ip_name          = "python-application-pip"
  app_gateway_name        = "python-application-appgateway"
  backend_address         = module.app_service.default_site_hostname
  backend_port            = 80
  zones                   = ["1"] # it should be ["1", "2", "3"] for high availability
}

module "application_insights" {
  source              = "./modules/application_insights"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  app_insights_name   = "python-application-appinsights"
}