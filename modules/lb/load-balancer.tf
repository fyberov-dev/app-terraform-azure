resource "azurerm_public_ip" "lb" {
    name                = "${var.prefix}-lb-ip"
    resource_group_name = var.resource_group_name
    location            = var.location
    allocation_method   = "Static"
    sku                 = "Standard"
}

resource "azurerm_lb" "lb" {
    name                = "${var.prefix}-lb"
    resource_group_name = var.resource_group_name
    location            = var.location
    sku                 = "Standard"

    frontend_ip_configuration {
      name                  = "frontend"
      public_ip_address_id  = azurerm_public_ip.lb.id
    }
}

resource "azurerm_lb_backend_address_pool" "app" {
    name            = "app-pool"
    loadbalancer_id = azurerm_lb.lb.id
}

resource "azurerm_lb_probe" "http" {
    name            = "http-probe"
    loadbalancer_id = azurerm_lb.lb.id
    protocol        = "Http"
    port            = 80
    request_path    = "/hello"
}

resource "azurerm_lb_rule" "http" {
    name                            = "http"
    loadbalancer_id                 = azurerm_lb.lb.id
    protocol                        = "Tcp"
    frontend_port                   = 80
    backend_port                    = 80
    frontend_ip_configuration_name  = "frontend"
    backend_address_pool_ids        = [azurerm_lb_backend_address_pool.app.id]
    probe_id                        = azurerm_lb_probe.http.id
    disable_outbound_snat           = true
}