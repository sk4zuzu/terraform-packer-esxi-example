terraform {
  required_version = "1.1.3"
  required_providers {
    esxi = {
      source = "josenk/esxi"
      version = "1.10.0"
    }
  }
}

variable "esxi_hostname" {
  type    = string
  default = "10.11.12.69"
}

variable "esxi_hostport" {
  type    = string
  default = "22"
}

variable "esxi_username" {
  type    = string
  default = "root"
}

variable "esxi_password" {
  type    = string
  default = "asd123X"
}

variable "guest_name" {
  type    = string
  default = "guest"
}

variable "disk_store" {
  type    = string
  default = "datastore1"
}

variable "virtual_network" {
  type    = string
  default = "VM Network"
}

variable "artifact" {
  type    = string
  default = "./../../files/bionic-server-cloudimg-amd64.ova"
}

locals {
  userdata = <<-EOF
  #cloud-config
  ssh_pwauth: false
  users:
    - name: "ubuntu"
      ssh_authorized_keys:
        - "${chomp(file("~/.ssh/id_rsa.pub"))}"
      sudo:
        - "ALL=(ALL) NOPASSWD:ALL"
      groups:
        - "sudo"
      shell: "/bin/bash"
    - name: "root"
      ssh_authorized_keys:
        - "${chomp(file("~/.ssh/id_rsa.pub"))}"
      shell: "/bin/bash"
  chpasswd:
    list:
      - "ubuntu:${var.esxi_password}"
    expire: false
  write_files:
    - content: |
        [Resolve]
        DNS=8.8.8.8
      path: "/etc/systemd/resolved.conf.d/google.conf"
  runcmd:
    - ["systemctl", "restart", "systemd-resolved.service"]
  EOF
}

provider "esxi" {
  esxi_hostname = var.esxi_hostname
  esxi_hostport = var.esxi_hostport
  esxi_username = var.esxi_username
  esxi_password = var.esxi_password
}

resource "esxi_guest" "guest" {
  guest_name = var.guest_name
  disk_store = var.disk_store

  network_interfaces {
    virtual_network = var.virtual_network
  }

  ovf_source = var.artifact

  ovf_properties_timer = 180
  ovf_properties {
    key   = "user-data"
    value = base64encode(local.userdata)
  }
}

output "ipv4" {
  value = esxi_guest.guest.ip_address
}
