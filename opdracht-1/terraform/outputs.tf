output "vm_name" {
  value = esxi_guest.vm.guest_name
}

output "vm_ip_address" {
  value = esxi_guest.vm.ip_address
}

output "inventory_file" {
  value = local_file.inventory.filename
}