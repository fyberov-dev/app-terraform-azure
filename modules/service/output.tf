output "service_private_ip_address" {
    value = azurerm_network_interface.service[0].private_ip_address
}