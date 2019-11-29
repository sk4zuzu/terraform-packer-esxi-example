
SELF := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

export

.PHONY: all requirements \
        binaries extras ovftool \
        hypervisor-disk \
        hypervisor \
        guest \
        destroy \
        clean

all: guest

requirements: binaries extras ovftool

binaries:
	make -f $(SELF)/Makefile.BINARIES

extras:
	make -f $(SELF)/Makefile.EXTRAS

ovftool:
	make -f $(SELF)/Makefile.OVFTOOL

hypervisor-disk:
	cd $(SELF)/packer/esxi/ && make build

hypervisor: hypervisor-disk
	cd $(SELF)/terraform/esxi/ && (terraform init && terraform apply)

guest: hypervisor
	for RETRY in {1..69}; do \
	    if (echo >/dev/tcp/10.11.12.69/22) &>/dev/null; then \
	        break; \
	    fi; \
	    sleep 2; \
	done && [[ "$$RETRY" -gt 0 ]] \
	&& cd $(SELF)/terraform/guest/ && (terraform init && terraform apply)

destroy:
	cd $(SELF)/terraform/esxi/ && (terraform init && terraform destroy)

clean:
	-make clean -f $(SELF)/Makefile.BINARIES
	-make clean -f $(SELF)/Makefile.EXTRAS
	-make clean -f $(SELF)/Makefile.OVFTOOL
	-cd $(SELF)/packer/esxi/ && make clean

# vim:ts=4:sw=4:noet:
