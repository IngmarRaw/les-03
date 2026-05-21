terraform {
  required_providers {
    esxi = {
      source = "registry.terraform.io/josenk/esxi"
    }
    local = {
      source = "hashicorp/local"
    }
  }
}

provider "esxi" {
  esxi_hostname = var.esxi_hostname
  esxi_hostport = var.esxi_hostport
  esxi_hostssl  = var.esxi_hostssl
  esxi_username = var.esxi_username
  esxi_password = var.esxi_password
}

locals {
  ssh_public_key = trimspace(file(var.ssh_public_key_path))
}

resource "esxi_guest" "webserver" {
  count      = 2
  guest_name = "webserver-${count.index + 1}"
  disk_store = var.disk_store

  memsize  = var.webserver_memory
  numvcpus = var.webserver_vcpu
  power    = "on"

  ovf_source = var.ovf_source

  network_interfaces {
    virtual_network = var.virtual_network
  }

  guestinfo = {
    "userdata" = base64gzip(templatefile("${path.module}/cloudinit.tftpl", {
      username       = var.vm_username
      ssh_public_key = local.ssh_public_key
    }))
    "userdata.encoding" = "gzip+base64"

    "metadata" = base64gzip(jsonencode({
      "local-hostname" = "webserver-${count.index + 1}"
      "instance-id"    = "webserver-${count.index + 1}"
    }))
    "metadata.encoding" = "gzip+base64"
  }
}

resource "esxi_guest" "databaseserver" {
  guest_name = "databaseserver"
  disk_store = var.disk_store

  memsize  = var.databaseserver_memory
  numvcpus = var.databaseserver_vcpu
  power    = "on"

  ovf_source = var.ovf_source

  network_interfaces {
    virtual_network = var.virtual_network
  }

  guestinfo = {
    "userdata" = base64gzip(templatefile("${path.module}/cloudinit.tftpl", {
      username       = var.vm_username
      ssh_public_key = local.ssh_public_key
    }))
    "userdata.encoding" = "gzip+base64"

    "metadata" = base64gzip(jsonencode({
      "local-hostname" = "databaseserver"
      "instance-id"    = "databaseserver"
    }))
    "metadata.encoding" = "gzip+base64"
  }
}

resource "local_file" "inventory" {
  filename = "${path.module}/../opdracht-4/inventory.ini"
  content = join("\n", concat(
    ["[web]"],
    [
      for vm in esxi_guest.webserver :
      "${vm.guest_name} ansible_host=${vm.ip_address} ansible_user=${var.vm_username}"
    ],
    [""],
    ["[db]"],
    [
      "${esxi_guest.databaseserver.guest_name} ansible_host=${esxi_guest.databaseserver.ip_address} ansible_user=${var.vm_username}"
    ]
  ))
}