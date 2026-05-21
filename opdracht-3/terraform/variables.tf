variable "esxi_hostname" {
  type = string
}

variable "esxi_hostport" {
  type    = string
  default = "22"
}

variable "esxi_hostssl" {
  type    = string
  default = "443"
}

variable "esxi_username" {
  type    = string
  default = "root"
}

variable "esxi_password" {
  type      = string
  sensitive = true
}

variable "disk_store" {
  type    = string
  default = "datastore1"
}

variable "virtual_network" {
  type    = string
  default = "VM Network"
}

variable "ovf_source" {
  type    = string
  default = "https://cloud-images.ubuntu.com/releases/24.04/release/ubuntu-24.04-server-cloudimg-amd64.ova"
}

variable "ssh_public_key_path" {
  type = string
}

variable "vm_username" {
  type    = string
  default = "iacuser"
}

variable "webserver_vcpu" {
  type    = string
  default = "1"
}

variable "webserver_memory" {
  type    = string
  default = "2048"
}

variable "databaseserver_vcpu" {
  type    = string
  default = "1"
}

variable "databaseserver_memory" {
  type    = string
  default = "2048"
}