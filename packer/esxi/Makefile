SHELL := $(shell which bash)
SELF  := $(patsubst %/,%,$(dir $(abspath $(firstword $(MAKEFILE_LIST)))))

NAME := esxi

ARTIFACT ?= VMware-VMvisor-Installer-7.0U3c-19035710.x86_64.iso
CHECKSUM ?= ad8ad131009588e0f1b7f52019b0978d36374eabce763311d7af09b6df0ff005

CPUS      ?= 2
MEMORY    ?= 4096
DISK_SIZE ?= 143360

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

  shutdown_timeout = "10m"

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
