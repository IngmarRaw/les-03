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

resource "esxi_guest" "vm" {
  guest_name = var.vm_name
  disk_store = var.disk_store

  memsize  = var.vm_memory
  numvcpus = var.vm_vcpu
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
      "local-hostname" = var.vm_name
      "instance-id"    = var.vm_name
    }))
    "metadata.encoding" = "gzip+base64"
  }
}

resource "local_file" "inventory" {
  filename = "${path.module}/inventory.ini"
  content = templatefile("${path.module}/inventory.tftpl", {
    hostname     = esxi_guest.vm.guest_name
    ip_address   = esxi_guest.vm.ip_address
    ansible_user = var.vm_username
  })
}