output "vnet_name" {
  value = azurerm_virtual_network.this.name
}

output "subnets" {
  value = azurerm_subnet.this[*].id
}