terraform {
    backend "azurerm" {}
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
    location = var.location
}

module "vnet" {
    source = "./modules/vnet"

    prefix = var.prefix
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
}

module "lb" {
    source = "./modules/lb"

    prefix = var.prefix
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
}

# module "wayout" {
#     source = "./modules/wayout"

#     prefix = var.prefix
#     resource_group_name = azurerm_resource_group.rg.name
#     location = azurerm_resource_group.rg.location
#     subnet_app_id = module.vnet.subnet_app_id
#     subnet_service_id = module.vnet.subnet_service_id
# }

module "db" {
    source = "./modules/db"

    prefix = var.prefix
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    db_login = var.db_login
    db_password = var.db_password
    vnet_id = module.vnet.vnet_id
    subnet_db_id = module.vnet.subnet_db_id
}

module "service" {
    source = "./modules/service"

    prefix = var.prefix
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    subnet_service_id = module.vnet.subnet_service_id
    beacon_image = var.beacon_image
    db_fqdn = module.db.db_fqdn
    admin_ssh_key = var.admin_ssh_key
    vm_size = var.vm_size
    db_login = var.db_login
    db_password = var.db_password
    admin_username = var.admin_username
    db_name = var.db_name
}

module "app" {
    source = "./modules/app"

    prefix = var.prefix
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    subnet_app_id = module.vnet.subnet_app_id
    backend_address_pool_id = module.lb.backend_address_pool_id
    beacon_image = var.beacon_image
    db_fqdn = module.db.db_fqdn
    admin_ssh_key = var.admin_ssh_key
    vm_size = var.vm_size
    service_private_ip_address = module.service.service_private_ip_address
    admin_username = var.admin_username

    depends_on = [ module.service ]
}