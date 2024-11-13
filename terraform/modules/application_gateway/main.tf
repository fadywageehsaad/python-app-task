resource "azurerm_public_ip" "this" {
  name                = var.public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  zones               = var.zones
}

resource "azurerm_application_gateway" "this" {
  name                = var.app_gateway_name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "example-gateway-ip-configuration"
    subnet_id = var.app_gateway_subnet_id
  }

  frontend_port {
    name = "frontendPort"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "example-frontend-ip"
    public_ip_address_id = azurerm_public_ip.this.id
  }

  backend_address_pool {
    name = "example-backend-pool"
    fqdns = [
      var.backend_address
    ]
  }

  backend_http_settings {
    name                                = "example-backend-http-settings"
    cookie_based_affinity               = "Disabled"
    port                                = var.backend_port
    protocol                            = "Http"
    request_timeout                     = 30
    probe_name                          = "example-probe-name"
    pick_host_name_from_backend_address = true
  }

  http_listener {
    name                           = "example-http-listener"
    frontend_ip_configuration_name = "example-frontend-ip"
    frontend_port_name             = "frontendPort"
    protocol                       = "Http"
  }

  probe {
    name                = "example-probe-name"
    protocol            = "Http"
    interval            = 30
    timeout             = 30
    path                = "/products"
    unhealthy_threshold = 3
    pick_host_name_from_backend_http_settings = true
    match {
      status_code = ["200-399"]
    }
  }

  request_routing_rule {
    name                       = "example-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "example-http-listener"
    backend_address_pool_name  = "example-backend-pool"
    backend_http_settings_name = "example-backend-http-settings"
    priority                   = 1
  }

  zones = var.zones
}

resource "azurerm_private_link_service" "example" {
  name                = "example-privatelink"
  location            = var.location
  resource_group_name = var.resource_group_name

  nat_ip_configuration {
    name      = azurerm_public_ip.this.name
    primary   = true
    subnet_id = var.endpoint_subnet_id
  }

  load_balancer_frontend_ip_configuration_ids = [
    azurerm_application_gateway.this.frontend_ip_configuration[0].id,
  ]
}

resource "azurerm_private_endpoint" "example" {
  name                = "example-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.endpoint_subnet_id

  private_service_connection {
    name                           = "example-privateserviceconnection"
    private_connection_resource_id = azurerm_private_link_service.example.id
    is_manual_connection           = false
  }
}