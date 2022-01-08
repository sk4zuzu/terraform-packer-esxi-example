SHELL := $(shell which bash)
SELF  := $(patsubst %/,%,$(dir $(abspath $(firstword $(MAKEFILE_LIST)))))

NAME := esxi

ARTIFACT ?= VMware-VMvisor-Installer-6.7.0.update03-14320388.x86_64.iso
CHECKSUM ?= fcbaa4cd952abd9e629fb131b8f46a949844405d8976372e7e5b55917623fbe0

CPUS      ?= 2
MEMORY    ?= 4096
DISK_SIZE ?= 70656

PACKER     := $(SELF)/../../bin/packer
PACKER_LOG ?= 1
HEADLESS   ?= true

define PACKERFILE
source "qemu" "$(NAME)" {
  accelerator = "kvm"

  iso_url      = "file://$(SELF)/../../files/$(ARTIFACT)"
  iso_checksum = "$(CHECKSUM)"

  cpus      = "$(CPUS)"
  qemuargs  = [["-cpu", "host"]]
  memory    = "$(MEMORY)"
  disk_size = "$(DISK_SIZE)"

  net_device     = "vmxnet3"
  disk_interface = "ide"

  communicator = "none"

  http_directory = "$(SELF)/http"

  boot_wait = "10s"
  boot_command = [
	"<leftShiftOn>O<leftShiftOff>",
	"<wait1s><spacebar>ks=http://{{.HTTPIP}}:{{.HTTPPort}}/esxi-ks.cfg<enter>",
  ]

  output_directory = "$(SELF)/.cache/output/"
  format           = "qcow2"
  vm_name          = "packer-$(NAME).qcow2"

  headless = $(HEADLESS)
}
build {
  sources = ["source.qemu.$(NAME)"]
}
endef

export

.PHONY: all

all: build

.PHONY: build

build: $(SELF)/.cache/output/packer-$(NAME).qcow2

$(SELF)/.cache/output/packer-$(NAME).qcow2: Makefile $(SELF)/http/esxi-ks.cfg
	install -d $(SELF)/.cache/
	if ! [[ -e $(SELF)/.cache/build.pkr.hcl ]]; then ln -s /dev/stdin $(SELF)/.cache/build.pkr.hcl; fi
	$(PACKER) build -force $(SELF)/.cache/build.pkr.hcl <<< "$$PACKERFILE"

.PHONY: clean

clean:
	-rm -rf $(SELF)/.cache/
