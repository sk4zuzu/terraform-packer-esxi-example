
terraform {
  required_version = ">= 0.12"
}

variable "vcpu" {
  type    = "string"
  default = "2"
}

variable "memory" {
  type    = "string"
  default = "4096"
}

variable "pool_directory" {
  type    = "string"
  default = "/stor/esxi"
}

variable "artifact" {
  type    = "string"
  default = "./../../packer/esxi/output/packer-esxi.qcow2"
}

locals {
  xslt = <<-EOF
  <?xml version="1.0" ?>
  <xsl:stylesheet version="1.0"
                  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output omit-xml-declaration="yes" indent="yes"/>
    <xsl:template match="node()|@*">
       <xsl:copy>
         <xsl:apply-templates select="node()|@*"/>
       </xsl:copy>
    </xsl:template>

    <xsl:template match="/domain/devices/interface[@type='network']/model/@type">
      <xsl:attribute name="type">
        <xsl:value-of select="'vmxnet3'"/>
      </xsl:attribute>
    </xsl:template>

    <xsl:template match="/domain/devices/disk[@type='volume']/target/@bus">
      <xsl:attribute name="bus">
        <xsl:value-of select="'ide'"/>
      </xsl:attribute>
    </xsl:template>

    <xsl:template match="/domain/devices/disk[@type='volume']/target/@dev">
      <xsl:attribute name="dev">
        <xsl:value-of select="'hda'"/>
      </xsl:attribute>
    </xsl:template>

  </xsl:stylesheet>
  EOF
}

provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_pool" "esxi" {
  name = "esxi"
  type = "dir"
  path = var.pool_directory
}

resource "libvirt_volume" "esxi" {
  name   = "esxi"
  pool   = libvirt_pool.esxi.name
  source = var.artifact
  format = "qcow2"
}

resource "libvirt_network" "esxi" {
   name      = "esxi"
   domain    = "esxi.local"
   mode      = "nat"
   addresses = [ "10.11.12.0/24" ]
}

resource "libvirt_domain" "esxi" {
  name   = "esxi"
  vcpu   = var.vcpu
  memory = var.memory

  cpu = {
    mode = "host-passthrough"
  }

  network_interface {
    network_id     = libvirt_network.esxi.id
    wait_for_lease = false
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.esxi.id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }

  xml {
    xslt = local.xslt
  }
}

# vim:ts=2:sw=2:et:
