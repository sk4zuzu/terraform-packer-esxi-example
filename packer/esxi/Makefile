
SELF := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

ARTIFACT ?= VMware-VMvisor-Installer-6.7.0.update03-14320388.x86_64.iso
CHECKSUM ?= fcbaa4cd952abd9e629fb131b8f46a949844405d8976372e7e5b55917623fbe0

CPUS      ?= 2
MEMORY    ?= 4096
DISK_SIZE ?= 70656

PACKER_LOG ?= 1
HEADLESS   ?= true

define Packerfile
{
	"builders": [{
		"type": "qemu",
		"accelerator": "kvm",

		"cpus": "$(CPUS)",
		"memory": "$(MEMORY)",
		"net_device": "vmxnet3",
		"qemuargs": [
			[ "-cpu", "host" ]
		],

		"disk_interface": "ide",
		"disk_size": "$(DISK_SIZE)",

		"iso_url": "file://$(SELF)/../../downloads/$(ARTIFACT)",
		"iso_checksum": "$(CHECKSUM)",
		"iso_checksum_type": "sha256",

		"http_directory": "$(SELF)/http",
		"boot_wait": "10s",
		"boot_command": [
			"<leftShiftOn>O<leftShiftOff>",
			"<wait1s><spacebar>ks=http://{{.HTTPIP}}:{{.HTTPPort}}/esxi-ks.cfg<enter>"
		],
		"communicator": "none",

		"output_directory": "$(SELF)/output",
		"format": "qcow2",

		"vm_name": "packer-esxi.qcow2",
		"headless": $(HEADLESS)
	}]
}
endef

export

.PHONY: all build clean

all: build

build: output/packer-esxi.qcow2

output/packer-esxi.qcow2: Makefile
	packer build -force - <<< "$$Packerfile"

clean:
	-rm -rf $(SELF)/output/

# vim:ts=4:sw=4:noet:
