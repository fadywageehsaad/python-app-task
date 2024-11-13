resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  address_space       = var.address_space
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "this" {
  count = length(var.subnets)

  name                 = var.subnets[count.index].subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.subnets[count.index].subnet_prefix]
  private_endpoint_network_policies = var.subnets[count.index].private_endpoint_network_policies
  private_link_service_network_policies_enabled = var.subnets[count.index].private_link_service_network_policies_enabled
}