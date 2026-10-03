resource "azurerm_virtual_network" "vnet" {
    name                = "${var.prefix}-vnet"
    resource_group_name = var.resource_group_name
    location            = var.location
    address_space       = ["10.60.0.0/16"]
}

resource "azurerm_subnet" "public" {
    name                    = "public"
    resource_group_name     = var.resource_group_name
    virtual_network_name    = azurerm_virtual_network.vnet.name
    address_prefixes        = ["10.60.0.0/24"]
}

resource "azurerm_subnet" "app" {
    name                            = "app"
    resource_group_name             = var.resource_group_name
    virtual_network_name            = azurerm_virtual_network.vnet.name
    address_prefixes                = ["10.60.1.0/24"]
    default_outbound_access_enabled = false
}

resource "azurerm_subnet" "db" {
    name                  = "db"
    resource_group_name   = var.resource_group_name
    virtual_network_name  = azurerm_virtual_network.vnet.name
    address_prefixes      = ["10.60.2.0/24"]
    service_endpoints = ["Microsoft.Storage"]
  
    delegation {
      name      = "postgres"
      service_delegation {
        name    = "Microsoft.DBforPostgreSQL/flexibleServers"
        actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
    }
}

resource "azurerm_subnet" "service" {
    name                            = "service"
    resource_group_name             = var.resource_group_name
    virtual_network_name            = azurerm_virtual_network.vnet.name
    address_prefixes                = ["10.60.3.0/24"]
    default_outbound_access_enabled = false
}
