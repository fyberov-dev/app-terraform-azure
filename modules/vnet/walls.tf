resource "azurerm_network_security_group" "app" {
    name                = "${var.prefix}-app-nsg"
    resource_group_name = var.resource_group_name
    location            = var.location

    security_rule {
        name                        = "http-in"
        priority                    = 100
        direction                   = "Inbound"
        access                      = "Allow"
        protocol                    = "Tcp"
        source_port_range           = "*"
        destination_port_range      = "80"
        source_address_prefix       = "Internet"
        destination_address_prefix  = "*"
    }
}

resource "azurerm_network_security_group" "db" {
    name                = "${var.prefix}-db-nsg"
    resource_group_name = var.resource_group_name
    location            = var.location

    security_rule {
        name                        = "postgres-from-service"
        priority                    = 100
        direction                   = "Inbound"
        access                      = "Allow"
        protocol                    = "Tcp"
        source_port_range           = "*"
        destination_port_range      = "5432"
        source_address_prefix       = "10.60.3.0/24"
        destination_address_prefix  = "*"
    }

    security_rule {
        name                        = "deny-vnet"
        priority                    = 4000
        direction                   = "Inbound"
        access                      = "Deny"
        protocol                    = "*"
        source_port_range           = "*"
        destination_port_range      = "*"
        source_address_prefix       = "VirtualNetwork"
        destination_address_prefix  = "*"
    }
}

resource "azurerm_network_security_group" "service" {
    name = "${var.prefix}-service-nsg"
    resource_group_name = var.resource_group_name
    location = var.location

    security_rule {
        name = "service-from-app"
        priority = 100
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "8080"
        source_address_prefix = "10.60.1.0/24"
        destination_address_prefix = "*"
    }
}

resource "azurerm_subnet_network_security_group_association" "app" {
    subnet_id                   = azurerm_subnet.app.id
    network_security_group_id   = azurerm_network_security_group.app.id
}

resource "azurerm_subnet_network_security_group_association" "db" {
    subnet_id                   = azurerm_subnet.db.id
    network_security_group_id   = azurerm_network_security_group.db.id
}

resource "azurerm_subnet_network_security_group_association" "service" {
    subnet_id                   = azurerm_subnet.service.id
    network_security_group_id   = azurerm_network_security_group.service.id
}