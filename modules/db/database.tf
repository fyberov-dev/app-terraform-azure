resource "azurerm_private_dns_zone" "db" {
    name                = "privatelink.postgres.database.azure.com"
    resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "db" {
    name                    = "${var.prefix}-db-dns-link"
    resource_group_name     = var.resource_group_name
    private_dns_zone_name   = azurerm_private_dns_zone.db.name
    virtual_network_id      = var.vnet_id
}

resource "azurerm_postgresql_flexible_server" "db" {
    name                            = "${var.prefix}-db"
    resource_group_name             = var.resource_group_name
    location                        = var.location
    version                         = "16"
    sku_name                        = "B_Standard_B1ms"
    storage_mb                      = 32768
    backup_retention_days           = 7
    administrator_login             = var.db_login
    administrator_password          = var.db_password
    delegated_subnet_id             = var.subnet_db_id
    private_dns_zone_id             = azurerm_private_dns_zone.db.id
    public_network_access_enabled   = false
    zone                            = "1"

    depends_on                      = [azurerm_private_dns_zone_virtual_network_link.db]
}