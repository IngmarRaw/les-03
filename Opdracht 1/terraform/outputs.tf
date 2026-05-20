output "vm_name" {
  value = azurerm_linux_virtual_machine.vm.name
}

output "public_ip" {
  value = azurerm_public_ip.vm.ip_address
}

output "inventory_file" {
  value = local_file.inventory.filename
}