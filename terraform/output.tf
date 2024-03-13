# Credentials

data "azurerm_client_config" "current" {
}

output "subscription_id" {
  value = data.azurerm_client_config.current.subscription_id
}

output "tenant_id" {
    value = data.azurerm_client_config.current.tenant_id
}

output "client_id" {
    value = data.azurerm_client_config.current.client_id
}

# 

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "public_ip_address" {
  value = azurerm_linux_virtual_machine.my_terraform_vm.public_ip_address
} 