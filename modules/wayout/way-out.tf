resource "azurerm_public_ip" "nat" {
    count               = var.locked ? 0 : 1
    name                = "${var.prefix}-nat-ip"
    resource_group_name = var.resource_group_name
    location            = var.location
    allocation_method   = "Static"
    sku                 = "Standard"
}

resource "azurerm_nat_gateway" "nat" {
    count               = var.locked ? 0 : 1
    name                = "${var.prefix}-nat"
    resource_group_name = var.resource_group_name
    location            = var.location
    sku_name            = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "nat" {
    count                   = var.locked ? 0 : 1
    nat_gateway_id          = azurerm_nat_gateway.nat[0].id
    public_ip_address_id    = azurerm_public_ip.nat[0].id
}

resource "azurerm_subnet_nat_gateway_association" "app" {
    count           = var.locked ? 0 : 1
    subnet_id       = var.subnet_app_id
    nat_gateway_id  = azurerm_nat_gateway.nat[0].id
}

resource "azurerm_subnet_nat_gateway_association" "service" {
    count           = var.locked ? 0 : 1
    subnet_id       = var.subnet_service_id
    nat_gateway_id  = azurerm_nat_gateway.nat[0].id
}