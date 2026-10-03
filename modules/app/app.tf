resource "azurerm_network_interface" "app" {
    count               = 2
    name                = "${var.prefix}-app-${count.index + 1}-nic"
    resource_group_name = var.resource_group_name
    location            = var.location

    ip_configuration {
        name                          = "internal"
        subnet_id                     = var.subnet_app_id
        private_ip_address_allocation = "Static"
        private_ip_address            = cidrhost("10.60.1.0/24", 10 + count.index)
    }
}

resource "azurerm_network_interface_backend_address_pool_association" "app" {
    count                   = 2
    network_interface_id    = azurerm_network_interface.app[count.index].id
    ip_configuration_name   = "internal"
    backend_address_pool_id = var.backend_address_pool_id
}

locals {
    app_cloud_init = base64encode(templatefile("${path.module}/cloud-init-app.yaml", {
        beacon_image = var.beacon_image
        api_url = "http://${var.service_private_ip_address}:8080"
        db_target = "${var.db_fqdn}:5432"
    }))
}

resource "azurerm_linux_virtual_machine" "app" {
    count                 = 2
    name                  = "${var.prefix}-app-${count.index + 1}"
    resource_group_name   = var.resource_group_name
    location              = var.location
    size                  = var.vm_size
    admin_username        = var.admin_username
    network_interface_ids = [azurerm_network_interface.app[count.index].id]
    custom_data           = local.app_cloud_init

    admin_ssh_key {
      username    = var.admin_username
      public_key  = var.admin_ssh_key
    }

    os_disk {
      caching              = "ReadWrite"
      storage_account_type = "Standard_LRS"
    }

    source_image_reference {
      publisher = "Canonical"
      offer     = "ubuntu-24_04-lts"
      sku       = "server"
      version   = "latest"
    }
}