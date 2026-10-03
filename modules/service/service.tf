resource "azurerm_network_interface" "service" {
    count               = 1
    name                = "${var.prefix}-service-1-nic"
    resource_group_name = var.resource_group_name
    location            = var.location

    ip_configuration {
        name                          = "internal"
        subnet_id                     = var.subnet_service_id
        private_ip_address_allocation = "Static"
        private_ip_address            = cidrhost("10.60.3.0/24", 10 + count.index)
  }
}

locals {
    service_cloud_init = base64encode(templatefile("${path.module}/cloud-init-service.yaml", {
        beacon_image = var.beacon_image
        db_target = "${var.db_fqdn}:5432"
        db_url = "postgres://${var.db_login}:${var.db_password}@${var.db_fqdn}/${var.db_name}?sslmode=require"
    }))
}

resource "azurerm_linux_virtual_machine" "service" {
    count                 = 1
    name                  = "${var.prefix}-service-${count.index + 1}"
    resource_group_name   = var.resource_group_name
    location              = var.location
    size                  = var.vm_size
    admin_username        = var.admin_username
    network_interface_ids = [azurerm_network_interface.service[count.index].id]
    custom_data           = local.service_cloud_init

    admin_ssh_key {
      username    = var.admin_username
      public_key  = var.admin_ssh_key
    }

    os_disk {
      caching               = "ReadWrite"
      storage_account_type  = "Standard_LRS"
    }

    source_image_reference {
      publisher = "Canonical"
      offer     = "ubuntu-24_04-lts"
      sku       = "server"
      version   = "latest"
    }
}