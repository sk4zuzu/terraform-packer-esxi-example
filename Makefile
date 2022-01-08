SHELL := $(shell which bash)
SELF  := $(patsubst %/,%,$(dir $(abspath $(firstword $(MAKEFILE_LIST)))))

export

.PHONY: all requirements \
        binaries ovftool \
        hypervisor-disk \
        hypervisor \
        guest \
        destroy \
        clean

all: guest

requirements: binaries ovftool

binaries:
	make -f $(SELF)/Makefile.BINARIES

ovftool:
	make -f $(SELF)/Makefile.OVFTOOL

hypervisor-disk:
	cd $(SELF)/packer/esxi/ && make build

hypervisor: hypervisor-disk
	cd $(SELF)/terraform/esxi/ && ($(SELF)/bin/terraform init && $(SELF)/bin/terraform apply)

guest: PATH := $(SELF)/bin:$(PATH)
guest: hypervisor
	for RETRY in {1..69}; do \
	    if (echo >/dev/tcp/10.11.12.69/22) &>/dev/null; then \
	        break; \
	    fi; \
	    sleep 2; \
	done && [[ "$$RETRY" -gt 0 ]]
	cd $(SELF)/terraform/guest/ && ($(SELF)/bin/terraform init && $(SELF)/bin/terraform apply)

destroy:
	cd $(SELF)/terraform/esxi/ && ($(SELF)/bin/terraform init && $(SELF)/bin/terraform destroy)

clean:
	-make clean -f $(SELF)/Makefile.BINARIES
	-make clean -f $(SELF)/Makefile.OVFTOOL
	-cd $(SELF)/packer/esxi/ && make clean
