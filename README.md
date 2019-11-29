
TERRAFORM-PACKER-ESXI-EXAMPLE
=============================

## 1. PURPOSE

Just a devops exercise.

## 2. FILES TO DOWNLOAD

```bash
gublyn:~/_git/terraform-packer-esxi-example/downloads$ ls -1
bionic-server-cloudimg-amd64.ova
VMware-ovftool-4.3.0-13981069-lin.x86_64.bundle
VMware-VMvisor-Installer-6.7.0.update03-14320388.x86_64.iso
```

## 3. INSTALL PACKER, TERRAFORM + PROVIDERS (NIXOS)

```bash
gublyn:~/_git/terraform-packer-esxi-example$ nix-shell --run "make requirements"
/nix/store/1zpvvxqxypyx2hlsg4zm7jdh1dc7z7cz-stdenv-linux/setup: line 813: /tmp/env-vars: Permission denied
make -f /home/gublyn/_git/terraform-packer-esxi-example/Makefile.BINARIES
make[1]: Entering directory '/home/gublyn/_git/terraform-packer-esxi-example'
rm -f /home/gublyn/go/bin/packer && ln -s /home/gublyn/go/bin/packer-1.4.5 /home/gublyn/go/bin/packer
rm -f /home/gublyn/go/bin/terraform && ln -s /home/gublyn/go/bin/terraform-0.12.13 /home/gublyn/go/bin/terraform
make[1]: Leaving directory '/home/gublyn/_git/terraform-packer-esxi-example'
make -f /home/gublyn/_git/terraform-packer-esxi-example/Makefile.EXTRAS
make[1]: Entering directory '/home/gublyn/_git/terraform-packer-esxi-example'
install -d /home/gublyn/go/src/github.com/dmacvicar/terraform-provider-libvirt/ && cd /home/gublyn/go/src/github.com/dmacvicar/terraform-provider-libvirt/ && git clone --branch=v0.6.0 https://github.com/dmacvicar/terraform-provider-libvirt.git . || ( git fetch origin v0.6.0 && git checkout v0.6.0 && git clean -df && git reset --hard v0.6.0 )
fatal: destination path '.' already exists and is not an empty directory.
From https://github.com/dmacvicar/terraform-provider-libvirt
 * tag                 v0.6.0     -> FETCH_HEAD
HEAD is now at 1c8597df Merge pull request #650 from xkwangcn/master
HEAD is now at 1c8597df Merge pull request #650 from xkwangcn/master
for REQUIREMENT in golang.org/x/crypto/ssh github.com/hashicorp/terraform github.com/tmc/scp; do \
    GOPATH=/home/gublyn/go go get -d -u $REQUIREMENT; \
done
cd /home/gublyn/go/src/github.com/dmacvicar/terraform-provider-libvirt/ && GOPATH=/home/gublyn/go go build -o /home/gublyn/go/bin/terraform-provider-libvirt-0.6.0
rm -f /home/gublyn/go/bin/terraform-provider-libvirt && ln -s /home/gublyn/go/bin/terraform-provider-libvirt-0.6.0 /home/gublyn/go/bin/terraform-provider-libvirt
install -d /home/gublyn/go/src/github.com/josenk/terraform-provider-esxi/ && cd /home/gublyn/go/src/github.com/josenk/terraform-provider-esxi/ && git clone --branch=v1.6.0 https://github.com/josenk/terraform-provider-esxi.git . || ( git fetch origin v1.6.0 && git checkout v1.6.0 && git clean -df && git reset --hard v1.6.0 )
fatal: destination path '.' already exists and is not an empty directory.
From https://github.com/josenk/terraform-provider-esxi
 * tag               v1.6.0     -> FETCH_HEAD
HEAD is now at 102c2ce Merge pull request #81 from josenk/v1.6.0/ovf_properties
HEAD is now at 102c2ce Merge pull request #81 from josenk/v1.6.0/ovf_properties
cd /home/gublyn/go/src/github.com/josenk/terraform-provider-esxi/ && GOPATH=/home/gublyn/go go build -o /home/gublyn/go/bin/terraform-provider-esxi-1.6.0
rm -f /home/gublyn/go/bin/terraform-provider-esxi && ln -s /home/gublyn/go/bin/terraform-provider-esxi-1.6.0 /home/gublyn/go/bin/terraform-provider-esxi
make[1]: Leaving directory '/home/gublyn/_git/terraform-packer-esxi-example'
make -f /home/gublyn/_git/terraform-packer-esxi-example/Makefile.OVFTOOL
make[1]: Entering directory '/home/gublyn/_git/terraform-packer-esxi-example'
docker build -t ovftool-extractor -f- /home/gublyn/_git/terraform-packer-esxi-example/ <<< "$Dockerfile" \
&& docker run -v /home/gublyn/_git/terraform-packer-esxi-example/ovftool/:/ovftool/ --rm -t ovftool-extractor
Sending build context to Docker daemon  695.6MB
Step 1/5 : FROM ubuntu:18.04
 ---> cf0f3ca922e0
Step 2/5 : COPY downloads/VMware-ovftool-4.3.0-13981069-lin.x86_64.bundle /tmp/installer.sh
 ---> Using cache
 ---> ba000838123c
Step 3/5 : RUN chmod +x /tmp/installer.sh && /tmp/installer.sh --eulas-agreed
 ---> Using cache
 ---> 87ad9ddab865
Step 4/5 : ENTRYPOINT []
 ---> Using cache
 ---> eddc3153726e
Step 5/5 : CMD cp -R /usr/lib/vmware-ovftool/* /ovftool/ && exec chown -R 6969:1 /ovftool/
 ---> Using cache
 ---> 989e2c6bceba
Successfully built 989e2c6bceba
Successfully tagged ovftool-extractor:latest
sed -i "1s:#!/bin/bash:#!/usr/bin/env bash:" /home/gublyn/_git/terraform-packer-esxi-example/ovftool/ovftool \
&& patchelf --set-interpreter /nix/store/pnd2kl27sag76h23wa5kl95a76n3k9i3-glibc-2.27/lib/ld-linux-x86-64.so.2 /home/gublyn/_git/terraform-packer-esxi-example/ovftool/ovftool.bin
warning: working around a Linux kernel bug by creating a hole of 2301952 bytes in ‘/home/gublyn/_git/terraform-packer-esxi-example/ovftool/ovftool.bin’
ln -s /home/gublyn/_git/terraform-packer-esxi-example/ovftool/ovftool /home/gublyn/go/bin/ovftool
make[1]: Leaving directory '/home/gublyn/_git/terraform-packer-esxi-example'
```

## 4. BUILD ESXI IMAGE, DEPLOY ESXI HYPERVISOR, DEPLOY SINGLE UBUNTU GUEST VM

```bash
gublyn:~/_git/terraform-packer-esxi-example$ PACKER_NO_LOG=1 TF_CLI_ARGS=-no-color make
cd /home/gublyn/_git/terraform-packer-esxi-example/packer/esxi/ && make build
make[1]: Entering directory '/home/gublyn/_git/terraform-packer-esxi-example/packer/esxi'
packer build -force - <<< "$Packerfile"
2019/11/29 16:24:49 [INFO] Packer version: 1.4.5
2019/11/29 16:24:49 Packer Target OS/Arch: linux amd64
2019/11/29 16:24:49 Built with Go Version: go1.13.4
2019/11/29 16:24:49 Detected home directory from env var: /home/gublyn
2019/11/29 16:24:49 Using internal plugin for hyperv-iso
2019/11/29 16:24:49 Using internal plugin for parallels-pvm
2019/11/29 16:24:49 Using internal plugin for amazon-ebssurrogate
2019/11/29 16:24:49 Using internal plugin for azure-chroot
2019/11/29 16:24:49 Using internal plugin for googlecompute
2019/11/29 16:24:49 Using internal plugin for osc-bsuvolume
2019/11/29 16:24:49 Using internal plugin for triton
2019/11/29 16:24:49 Using internal plugin for vmware-iso
2019/11/29 16:24:49 Using internal plugin for vmware-vmx
2019/11/29 16:24:49 Using internal plugin for amazon-ebs
2019/11/29 16:24:49 Using internal plugin for amazon-ebsvolume
2019/11/29 16:24:49 Using internal plugin for jdcloud
2019/11/29 16:24:49 Using internal plugin for ncloud
2019/11/29 16:24:49 Using internal plugin for alicloud-ecs
2019/11/29 16:24:49 Using internal plugin for cloudstack
2019/11/29 16:24:49 Using internal plugin for hyperone
2019/11/29 16:24:49 Using internal plugin for lxc
2019/11/29 16:24:49 Using internal plugin for osc-bsusurrogate
2019/11/29 16:24:49 Using internal plugin for parallels-iso
2019/11/29 16:24:49 Using internal plugin for scaleway
2019/11/29 16:24:49 Using internal plugin for tencentcloud-cvm
2019/11/29 16:24:49 Using internal plugin for azure-arm
2019/11/29 16:24:49 Using internal plugin for digitalocean
2019/11/29 16:24:49 Using internal plugin for file
2019/11/29 16:24:49 Using internal plugin for ucloud-uhost
2019/11/29 16:24:49 Using internal plugin for null
2019/11/29 16:24:49 Using internal plugin for openstack
2019/11/29 16:24:49 Using internal plugin for oracle-classic
2019/11/29 16:24:49 Using internal plugin for proxmox
2019/11/29 16:24:49 Using internal plugin for qemu
2019/11/29 16:24:49 Using internal plugin for amazon-instance
2019/11/29 16:24:49 Using internal plugin for hyperv-vmcx
2019/11/29 16:24:49 Using internal plugin for linode
2019/11/29 16:24:49 Using internal plugin for yandex
2019/11/29 16:24:49 Using internal plugin for vagrant
2019/11/29 16:24:49 Using internal plugin for amazon-chroot
2019/11/29 16:24:49 Using internal plugin for oneandone
2019/11/29 16:24:49 Using internal plugin for osc-bsu
2019/11/29 16:24:49 Using internal plugin for virtualbox-iso
2019/11/29 16:24:49 Using internal plugin for virtualbox-ovf
2019/11/29 16:24:49 Using internal plugin for lxd
2019/11/29 16:24:49 Using internal plugin for oracle-oci
2019/11/29 16:24:49 Using internal plugin for profitbricks
2019/11/29 16:24:49 Using internal plugin for virtualbox-vm
2019/11/29 16:24:49 Using internal plugin for docker
2019/11/29 16:24:49 Using internal plugin for hcloud
2019/11/29 16:24:49 Using internal plugin for osc-chroot
2019/11/29 16:24:49 Using internal plugin for ansible-local
2019/11/29 16:24:49 Using internal plugin for chef-solo
2019/11/29 16:24:49 Using internal plugin for inspec
2019/11/29 16:24:49 Using internal plugin for shell-local
2019/11/29 16:24:49 Using internal plugin for file
2019/11/29 16:24:49 Using internal plugin for puppet-server
2019/11/29 16:24:49 Using internal plugin for sleep
2019/11/29 16:24:49 Using internal plugin for windows-shell
2019/11/29 16:24:49 Using internal plugin for breakpoint
2019/11/29 16:24:49 Using internal plugin for converge
2019/11/29 16:24:49 Using internal plugin for powershell
2019/11/29 16:24:49 Using internal plugin for salt-masterless
2019/11/29 16:24:49 Using internal plugin for shell
2019/11/29 16:24:49 Using internal plugin for ansible
2019/11/29 16:24:49 Using internal plugin for chef-client
2019/11/29 16:24:49 Using internal plugin for puppet-masterless
2019/11/29 16:24:49 Using internal plugin for windows-restart
2019/11/29 16:24:49 Using internal plugin for manifest
2019/11/29 16:24:49 Using internal plugin for ucloud-import
2019/11/29 16:24:49 Using internal plugin for vsphere
2019/11/29 16:24:49 Using internal plugin for alicloud-import
2019/11/29 16:24:49 Using internal plugin for digitalocean-import
2019/11/29 16:24:49 Using internal plugin for docker-push
2019/11/29 16:24:49 Using internal plugin for checksum
2019/11/29 16:24:49 Using internal plugin for compress
2019/11/29 16:24:49 Using internal plugin for docker-tag
2019/11/29 16:24:49 Using internal plugin for shell-local
2019/11/29 16:24:49 Using internal plugin for vagrant-cloud
2019/11/29 16:24:49 Using internal plugin for amazon-import
2019/11/29 16:24:49 Using internal plugin for artifice
2019/11/29 16:24:49 Using internal plugin for googlecompute-export
2019/11/29 16:24:49 Using internal plugin for googlecompute-import
2019/11/29 16:24:49 Using internal plugin for vagrant
2019/11/29 16:24:49 Using internal plugin for vsphere-template
2019/11/29 16:24:49 Using internal plugin for docker-import
2019/11/29 16:24:49 Using internal plugin for docker-save
2019/11/29 16:24:49 Using internal plugin for exoscale-import
2019/11/29 16:24:49 Detected home directory from env var: /home/gublyn
2019/11/29 16:24:49 Attempting to open config file: /home/gublyn/.packerconfig
2019/11/29 16:24:49 [WARN] Config file doesn't exist: /home/gublyn/.packerconfig
2019/11/29 16:24:49 Packer config: &{DisableCheckpoint:false DisableCheckpointSignature:false PluginMinPort:10000 PluginMaxPort:25000 Builders:map[alicloud-ecs:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-alicloud-ecs amazon-chroot:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-amazon-chroot amazon-ebs:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-amazon-ebs amazon-ebssurrogate:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-amazon-ebssurrogate amazon-ebsvolume:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-amazon-ebsvolume amazon-instance:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-amazon-instance azure-arm:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-azure-arm azure-chroot:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-azure-chroot cloudstack:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-cloudstack digitalocean:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-digitalocean docker:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-docker file:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-file googlecompute:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-googlecompute hcloud:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-hcloud hyperone:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-hyperone hyperv-iso:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-hyperv-iso hyperv-vmcx:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-hyperv-vmcx jdcloud:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-jdcloud linode:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-linode lxc:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-lxc lxd:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-lxd ncloud:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-ncloud null:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-null oneandone:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-oneandone openstack:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-openstack oracle-classic:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-oracle-classic oracle-oci:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-oracle-oci osc-bsu:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-osc-bsu osc-bsusurrogate:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-osc-bsusurrogate osc-bsuvolume:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-osc-bsuvolume osc-chroot:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-osc-chroot parallels-iso:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-parallels-iso parallels-pvm:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-parallels-pvm profitbricks:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-profitbricks proxmox:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-proxmox qemu:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-qemu scaleway:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-scaleway tencentcloud-cvm:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-tencentcloud-cvm triton:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-triton ucloud-uhost:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-ucloud-uhost vagrant:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-vagrant virtualbox-iso:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-virtualbox-iso virtualbox-ovf:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-virtualbox-ovf virtualbox-vm:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-virtualbox-vm vmware-iso:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-vmware-iso vmware-vmx:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-vmware-vmx yandex:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-builder-yandex] PostProcessors:map[alicloud-import:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-post-processor-alicloud-import amazon-import:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-post-processor-amazon-import artifice:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-post-processor-artifice checksum:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-post-processor-checksum compress:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-post-processor-compress digitalocean-import:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-post-processor-digitalocean-import docker-import:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-post-processor-docker-import docker-push:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-post-processor-docker-push docker-save:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-post-processor-docker-save docker-tag:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-post-processor-docker-tag exoscale-import:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-post-processor-exoscale-import googlecompute-export:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-post-processor-googlecompute-export googlecompute-import:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-post-processor-googlecompute-import manifest:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-post-processor-manifest shell-local:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-post-processor-shell-local ucloud-import:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-post-processor-ucloud-import vagrant:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-post-processor-vagrant vagrant-cloud:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-post-processor-vagrant-cloud vsphere:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-post-processor-vsphere vsphere-template:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-post-processor-vsphere-template] Provisioners:map[ansible:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-provisioner-ansible ansible-local:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-provisioner-ansible-local breakpoint:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-provisioner-breakpoint chef-client:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-provisioner-chef-client chef-solo:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-provisioner-chef-solo converge:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-provisioner-converge file:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-provisioner-file inspec:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-provisioner-inspec powershell:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-provisioner-powershell puppet-masterless:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-provisioner-puppet-masterless puppet-server:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-provisioner-puppet-server salt-masterless:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-provisioner-salt-masterless shell:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-provisioner-shell shell-local:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-provisioner-shell-local sleep:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-provisioner-sleep windows-restart:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-provisioner-windows-restart windows-shell:/home/gublyn/go/bin/packer-1.4.5-PACKERSPACE-plugin-PACKERSPACE-packer-provisioner-windows-shell]}
2019/11/29 16:24:49 Detected home directory from env var: /home/gublyn
2019/11/29 16:24:49 Setting cache directory: /home/gublyn/_git/terraform-packer-esxi-example/packer/esxi/packer_cache
2019/11/29 16:24:49 Detected home directory from env var: /home/gublyn
2019/11/29 16:24:49 Loading builder: qemu
2019/11/29 16:24:49 Plugin could not be found. Checking same directory as executable.
2019/11/29 16:24:49 Current exe path: /home/gublyn/go/bin/packer-1.4.5
2019/11/29 16:24:49 Creating plugin client for path: /home/gublyn/go/bin/packer-1.4.5
2019/11/29 16:24:49 Starting plugin: /home/gublyn/go/bin/packer-1.4.5 []string{"/home/gublyn/go/bin/packer-1.4.5", "plugin", "packer-builder-qemu"}
2019/11/29 16:24:49 Waiting for RPC address for: /home/gublyn/go/bin/packer-1.4.5
2019/11/29 16:24:49 packer-1.4.5: 2019/11/29 16:24:49 [INFO] Packer version: 1.4.5
2019/11/29 16:24:49 packer-1.4.5: 2019/11/29 16:24:49 Packer Target OS/Arch: linux amd64
2019/11/29 16:24:49 packer-1.4.5: 2019/11/29 16:24:49 Built with Go Version: go1.13.4
2019/11/29 16:24:49 packer-1.4.5: 2019/11/29 16:24:49 Detected home directory from env var: /home/gublyn
2019/11/29 16:24:49 packer-1.4.5: 2019/11/29 16:24:49 Attempting to open config file: /home/gublyn/.packerconfig
2019/11/29 16:24:49 packer-1.4.5: 2019/11/29 16:24:49 [WARN] Config file doesn't exist: /home/gublyn/.packerconfig
2019/11/29 16:24:49 packer-1.4.5: 2019/11/29 16:24:49 Packer config: &{DisableCheckpoint:false DisableCheckpointSignature:false PluginMinPort:10000 PluginMaxPort:25000 Builders:map[] PostProcessors:map[] Provisioners:map[]}
2019/11/29 16:24:49 packer-1.4.5: 2019/11/29 16:24:49 Detected home directory from env var: /home/gublyn
2019/11/29 16:24:49 packer-1.4.5: 2019/11/29 16:24:49 Setting cache directory: /home/gublyn/_git/terraform-packer-esxi-example/packer/esxi/packer_cache
2019/11/29 16:24:49 packer-1.4.5: 2019/11/29 16:24:49 args: []string{"packer-builder-qemu"}
2019/11/29 16:24:49 packer-1.4.5: 2019/11/29 16:24:49 Plugin minimum port: 10000
2019/11/29 16:24:49 packer-1.4.5: 2019/11/29 16:24:49 Plugin maximum port: 25000
2019/11/29 16:24:49 packer-1.4.5: 2019/11/29 16:24:49 Plugin address: unix /tmp/packer-plugin238068272
2019/11/29 16:24:49 packer-1.4.5: 2019/11/29 16:24:49 Waiting for connection...
2019/11/29 16:24:49 packer-1.4.5: 2019/11/29 16:24:49 Detected home directory from env var: /home/gublyn
2019/11/29 16:24:49 packer-1.4.5: 2019/11/29 16:24:49 Serving a plugin connection...
2019/11/29 16:24:49 Build debug mode: false
2019/11/29 16:24:49 Force build: true
2019/11/29 16:24:49 On error: 
2019/11/29 16:24:49 Preparing build: qemu
qemu output will be in this color.

2019/11/29 16:24:49 packer-1.4.5: 2019/11/29 16:24:49 use specified accelerator: kvm
2019/11/29 16:24:49 Waiting on builds to complete...
2019/11/29 16:24:49 Starting build run: qemu
2019/11/29 16:24:49 Running builder: qemu
2019/11/29 16:24:49 [INFO] (telemetry) Starting builder qemu
2019/11/29 16:24:49 packer-1.4.5: 2019/11/29 16:24:49 Qemu path: /run/current-system/sw/bin/qemu-system-x86_64, Qemu Image page: /run/current-system/sw/bin/qemu-img
==> qemu: Retrieving ISO
2019/11/29 16:24:49 packer-1.4.5: 2019/11/29 16:24:49 Acquiring lock for: file:///home/gublyn/_git/terraform-packer-esxi-example/packer/esxi/../../downloads/VMware-VMvisor-Installer-6.7.0.update03-14320388.x86_64.iso?checksum=sha256%3Afcbaa4cd952abd9e629fb131b8f46a949844405d8976372e7e5b55917623fbe0 (/home/gublyn/_git/terraform-packer-esxi-example/packer/esxi/packer_cache/de834621d6e1cd57e7c8cd536cbd339fb0abaf62.iso.lock)
==> qemu: Trying file:///home/gublyn/_git/terraform-packer-esxi-example/packer/esxi/../../downloads/VMware-VMvisor-Installer-6.7.0.update03-14320388.x86_64.iso
==> qemu: Trying file:///home/gublyn/_git/terraform-packer-esxi-example/packer/esxi/../../downloads/VMware-VMvisor-Installer-6.7.0.update03-14320388.x86_64.iso?checksum=sha256%3Afcbaa4cd952abd9e629fb131b8f46a949844405d8976372e7e5b55917623fbe0
==> qemu: file:///home/gublyn/_git/terraform-packer-esxi-example/packer/esxi/../../downloads/VMware-VMvisor-Installer-6.7.0.update03-14320388.x86_64.iso?checksum=sha256%3Afcbaa4cd952abd9e629fb131b8f46a949844405d8976372e7e5b55917623fbe0 => /home/gublyn/_git/terraform-packer-esxi-example/packer/esxi/packer_cache/de834621d6e1cd57e7c8cd536cbd339fb0abaf62.iso
2019/11/29 16:24:50 packer-1.4.5: 2019/11/29 16:24:50 Leaving retrieve loop for ISO
2019/11/29 16:24:50 packer-1.4.5: 2019/11/29 16:24:50 No floppy files specified. Floppy disk will not be made.
==> qemu: Creating required virtual machine disks
2019/11/29 16:24:50 packer-1.4.5: 2019/11/29 16:24:50 [INFO] Creating disk with Path: /home/gublyn/_git/terraform-packer-esxi-example/packer/esxi/output/packer-esxi.qcow2 and Size: 70656M
2019/11/29 16:24:50 packer-1.4.5: 2019/11/29 16:24:50 Executing qemu-img: []string{"create", "-f", "qcow2", "/home/gublyn/_git/terraform-packer-esxi-example/packer/esxi/output/packer-esxi.qcow2", "70656M"}
2019/11/29 16:24:50 packer-1.4.5: 2019/11/29 16:24:50 stdout: Formatting '/home/gublyn/_git/terraform-packer-esxi-example/packer/esxi/output/packer-esxi.qcow2', fmt=qcow2 size=74088185856 cluster_size=65536 lazy_refcounts=off refcount_bits=16
2019/11/29 16:24:50 packer-1.4.5: 2019/11/29 16:24:50 stderr:
2019/11/29 16:24:50 packer-1.4.5: 2019/11/29 16:24:50 Found available port: 8713 on IP: 0.0.0.0
==> qemu: Starting HTTP server on port 8713
2019/11/29 16:24:50 packer-1.4.5: 2019/11/29 16:24:50 Looking for available port between 5900 and 6000 on 127.0.0.1
==> qemu: Looking for available port between 5900 and 6000 on 127.0.0.1
2019/11/29 16:24:50 packer-1.4.5: 2019/11/29 16:24:50 Found available port: 5957 on IP: 127.0.0.1
2019/11/29 16:24:50 packer-1.4.5: 2019/11/29 16:24:50 Found available VNC port: 5957 on IP: 127.0.0.1
==> qemu: Starting VM, booting from CD-ROM
2019/11/29 16:24:50 packer-1.4.5: 2019/11/29 16:24:50 Qemu --version output: QEMU emulator version 4.0.1
2019/11/29 16:24:50 packer-1.4.5: Copyright (c) 2003-2019 Fabrice Bellard and the QEMU Project developers
2019/11/29 16:24:50 packer-1.4.5: 2019/11/29 16:24:50 Qemu version: 4.0.1
    qemu: view the screen of the VM, connect via VNC without a password to
    qemu: vnc://127.0.0.1:5957
    qemu: The VM will be run headless, without a GUI. If you want to
2019/11/29 16:24:50 packer-1.4.5: 2019/11/29 16:24:50 Qemu Builder has no floppy files, not attaching a floppy.
    qemu: view the screen of the VM, connect via VNC without a password to
    qemu: vnc://127.0.0.1:5957
==> qemu: Overriding defaults Qemu arguments with QemuArgs...
2019/11/29 16:24:50 packer-1.4.5: 2019/11/29 16:24:50 Executing /run/current-system/sw/bin/qemu-system-x86_64: []string{"-cdrom", "/home/gublyn/_git/terraform-packer-esxi-example/packer/esxi/packer_cache/de834621d6e1cd57e7c8cd536cbd339fb0abaf62.iso", "-vnc", "127.0.0.1:57", "-machine", "type=pc,accel=kvm", "-boot", "once=d", "-m", "4096M", "-name", "packer-esxi.qcow2", "-netdev", "user,id=user.0", "-cpu", "host", "-drive", "file=/home/gublyn/_git/terraform-packer-esxi-example/packer/esxi/output/packer-esxi.qcow2,if=ide,cache=writeback,discard=ignore,format=qcow2", "-smp", "cpus=2,sockets=2", "-device", "vmxnet3,netdev=user.0"}
2019/11/29 16:24:50 packer-1.4.5: 2019/11/29 16:24:50 Started Qemu. Pid: 28483
==> qemu: Waiting 10s for boot...
==> qemu: Connecting to VM via VNC (127.0.0.1:5957)
2019/11/29 16:25:02 packer-1.4.5: 2019/11/29 16:25:02 Connected to VNC desktop: QEMU (packer-esxi.qcow2)
==> qemu: Typing the boot command over VNC...
2019/11/29 16:25:02 packer-1.4.5: 2019/11/29 16:25:02 Special code '<leftshift>' found, replacing with: 0xFFE1
2019/11/29 16:25:02 packer-1.4.5: 2019/11/29 16:25:02 Sending char 'O', code 0x4F, shift true
2019/11/29 16:25:02 packer-1.4.5: 2019/11/29 16:25:02 Special code '<leftshift>' found, replacing with: 0xFFE1
2019/11/29 16:25:02 packer-1.4.5: 2019/11/29 16:25:02 [INFO] Waiting 1s
2019/11/29 16:25:03 packer-1.4.5: 2019/11/29 16:25:03 Special code '<spacebar>' found, replacing with: 0x20
2019/11/29 16:25:04 packer-1.4.5: 2019/11/29 16:25:04 Sending char 'k', code 0x6B, shift false
2019/11/29 16:25:04 packer-1.4.5: 2019/11/29 16:25:04 Sending char 's', code 0x73, shift false
2019/11/29 16:25:04 packer-1.4.5: 2019/11/29 16:25:04 Sending char '=', code 0x3D, shift false
2019/11/29 16:25:04 packer-1.4.5: 2019/11/29 16:25:04 Sending char 'h', code 0x68, shift false
2019/11/29 16:25:04 packer-1.4.5: 2019/11/29 16:25:04 Sending char 't', code 0x74, shift false
2019/11/29 16:25:05 packer-1.4.5: 2019/11/29 16:25:05 Sending char 't', code 0x74, shift false
2019/11/29 16:25:05 packer-1.4.5: 2019/11/29 16:25:05 Sending char 'p', code 0x70, shift false
2019/11/29 16:25:05 packer-1.4.5: 2019/11/29 16:25:05 Sending char ':', code 0x3A, shift true
2019/11/29 16:25:05 packer-1.4.5: 2019/11/29 16:25:05 Sending char '/', code 0x2F, shift false
2019/11/29 16:25:06 packer-1.4.5: 2019/11/29 16:25:06 Sending char '/', code 0x2F, shift false
2019/11/29 16:25:06 packer-1.4.5: 2019/11/29 16:25:06 Sending char '1', code 0x31, shift false
2019/11/29 16:25:06 packer-1.4.5: 2019/11/29 16:25:06 Sending char '0', code 0x30, shift false
2019/11/29 16:25:06 packer-1.4.5: 2019/11/29 16:25:06 Sending char '.', code 0x2E, shift false
2019/11/29 16:25:06 packer-1.4.5: 2019/11/29 16:25:06 Sending char '0', code 0x30, shift false
2019/11/29 16:25:07 packer-1.4.5: 2019/11/29 16:25:07 Sending char '.', code 0x2E, shift false
2019/11/29 16:25:07 packer-1.4.5: 2019/11/29 16:25:07 Sending char '2', code 0x32, shift false
2019/11/29 16:25:07 packer-1.4.5: 2019/11/29 16:25:07 Sending char '.', code 0x2E, shift false
2019/11/29 16:25:07 packer-1.4.5: 2019/11/29 16:25:07 Sending char '2', code 0x32, shift false
2019/11/29 16:25:07 packer-1.4.5: 2019/11/29 16:25:07 Sending char ':', code 0x3A, shift true
2019/11/29 16:25:08 packer-1.4.5: 2019/11/29 16:25:08 Sending char '8', code 0x38, shift false
2019/11/29 16:25:08 packer-1.4.5: 2019/11/29 16:25:08 Sending char '7', code 0x37, shift false
2019/11/29 16:25:08 packer-1.4.5: 2019/11/29 16:25:08 Sending char '1', code 0x31, shift false
2019/11/29 16:25:08 packer-1.4.5: 2019/11/29 16:25:08 Sending char '3', code 0x33, shift false
2019/11/29 16:25:09 packer-1.4.5: 2019/11/29 16:25:09 Sending char '/', code 0x2F, shift false
2019/11/29 16:25:09 packer-1.4.5: 2019/11/29 16:25:09 Sending char 'e', code 0x65, shift false
2019/11/29 16:25:09 packer-1.4.5: 2019/11/29 16:25:09 Sending char 's', code 0x73, shift false
2019/11/29 16:25:09 packer-1.4.5: 2019/11/29 16:25:09 Sending char 'x', code 0x78, shift false
2019/11/29 16:25:09 packer-1.4.5: 2019/11/29 16:25:09 Sending char 'i', code 0x69, shift false
2019/11/29 16:25:10 packer-1.4.5: 2019/11/29 16:25:10 Sending char '-', code 0x2D, shift false
2019/11/29 16:25:10 packer-1.4.5: 2019/11/29 16:25:10 Sending char 'k', code 0x6B, shift false
2019/11/29 16:25:10 packer-1.4.5: 2019/11/29 16:25:10 Sending char 's', code 0x73, shift false
2019/11/29 16:25:10 packer-1.4.5: 2019/11/29 16:25:10 Sending char '.', code 0x2E, shift false
2019/11/29 16:25:10 packer-1.4.5: 2019/11/29 16:25:10 Sending char 'c', code 0x63, shift false
2019/11/29 16:25:11 packer-1.4.5: 2019/11/29 16:25:11 Sending char 'f', code 0x66, shift false
2019/11/29 16:25:11 packer-1.4.5: 2019/11/29 16:25:11 Sending char 'g', code 0x67, shift false
2019/11/29 16:25:11 packer-1.4.5: 2019/11/29 16:25:11 Special code '<enter>' found, replacing with: 0xFF0D
2019/11/29 16:25:11 packer-1.4.5: 2019/11/29 16:25:11 Running the provision hook
==> qemu: Waiting for shutdown...
2019/11/29 16:27:20 packer-1.4.5: 2019/11/29 16:27:20 VM shut down.
==> qemu: Converting hard drive...
2019/11/29 16:27:20 packer-1.4.5: 2019/11/29 16:27:20 Executing qemu-img: []string{"convert", "-O", "qcow2", "/home/gublyn/_git/terraform-packer-esxi-example/packer/esxi/output/packer-esxi.qcow2", "/home/gublyn/_git/terraform-packer-esxi-example/packer/esxi/output/packer-esxi.qcow2.convert"}
2019/11/29 16:27:20 packer-1.4.5: 2019/11/29 16:27:20 stdout:
2019/11/29 16:27:20 packer-1.4.5: 2019/11/29 16:27:20 stderr:
2019/11/29 16:27:20 packer-1.4.5: 2019/11/29 16:27:20 failed to unlock port lockfile: close tcp 127.0.0.1:5957: use of closed network connection
2019/11/29 16:27:20 [INFO] (telemetry) ending qemu
==> Builds finished. The artifacts of successful builds are:
2019/11/29 16:27:20 machine readable: qemu,artifact-count []string{"1"}
Build 'qemu' finished.

==> Builds finished. The artifacts of successful builds are:
2019/11/29 16:27:20 machine readable: qemu,artifact []string{"0", "builder-id", "transcend.qemu"}
2019/11/29 16:27:20 machine readable: qemu,artifact []string{"0", "id", "VM"}
2019/11/29 16:27:20 machine readable: qemu,artifact []string{"0", "string", "VM files in directory: /home/gublyn/_git/terraform-packer-esxi-example/packer/esxi/output"}
2019/11/29 16:27:20 machine readable: qemu,artifact []string{"0", "files-count", "1"}
2019/11/29 16:27:20 machine readable: qemu,artifact []string{"0", "file", "0", "/home/gublyn/_git/terraform-packer-esxi-example/packer/esxi/output/packer-esxi.qcow2"}
2019/11/29 16:27:20 machine readable: qemu,artifact []string{"0", "end"}
--> qemu: VM files in directory: /home/gublyn/_git/terraform-packer-esxi-example/packer/esxi/output
2019/11/29 16:27:20 [INFO] (telemetry) Finalizing.
2019/11/29 16:27:21 waiting for all plugin processes to complete...
2019/11/29 16:27:21 /home/gublyn/go/bin/packer-1.4.5: plugin process exited
make[1]: Leaving directory '/home/gublyn/_git/terraform-packer-esxi-example/packer/esxi'
cd /home/gublyn/_git/terraform-packer-esxi-example/terraform/esxi/ && (terraform init && terraform apply)

Initializing the backend...

Initializing provider plugins...

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # libvirt_domain.esxi will be created
  + resource "libvirt_domain" "esxi" {
      + arch        = (known after apply)
      + cpu         = {
          + "mode" = "host-passthrough"
        }
      + emulator    = (known after apply)
      + fw_cfg_name = "opt/com.coreos/config"
      + id          = (known after apply)
      + machine     = (known after apply)
      + memory      = 4096
      + name        = "esxi"
      + qemu_agent  = false
      + running     = true
      + vcpu        = 2

      + console {
          + source_host    = "127.0.0.1"
          + source_service = "0"
          + target_port    = "0"
          + target_type    = "serial"
          + type           = "pty"
        }
      + console {
          + source_host    = "127.0.0.1"
          + source_service = "0"
          + target_port    = "1"
          + target_type    = "virtio"
          + type           = "pty"
        }

      + disk {
          + scsi      = false
          + volume_id = (known after apply)
        }

      + graphics {
          + autoport       = true
          + listen_address = "127.0.0.1"
          + listen_type    = "address"
          + type           = "spice"
        }

      + network_interface {
          + addresses      = (known after apply)
          + hostname       = (known after apply)
          + mac            = (known after apply)
          + network_id     = (known after apply)
          + network_name   = (known after apply)
          + wait_for_lease = false
        }

      + xml {
          + xslt = "<?xml version=\"1.0\" ?>\n<xsl:stylesheet version=\"1.0\"\n                xmlns:xsl=\"http://www.w3.org/1999/XSL/Transform\">\n\n  <xsl:output omit-xml-declaration=\"yes\" indent=\"yes\"/>\n  <xsl:template match=\"node()|@*\">\n     <xsl:copy>\n       <xsl:apply-templates select=\"node()|@*\"/>\n     </xsl:copy>\n  </xsl:template>\n\n  <xsl:template match=\"/domain/devices/interface[@type='network']/model/@type\">\n    <xsl:attribute name=\"type\">\n      <xsl:value-of select=\"'vmxnet3'\"/>\n    </xsl:attribute>\n  </xsl:template>\n\n  <xsl:template match=\"/domain/devices/disk[@type='volume']/target/@bus\">\n    <xsl:attribute name=\"bus\">\n      <xsl:value-of select=\"'ide'\"/>\n    </xsl:attribute>\n  </xsl:template>\n\n  <xsl:template match=\"/domain/devices/disk[@type='volume']/target/@dev\">\n    <xsl:attribute name=\"dev\">\n      <xsl:value-of select=\"'hda'\"/>\n    </xsl:attribute>\n  </xsl:template>\n\n</xsl:stylesheet>\n"
        }
    }

  # libvirt_network.esxi will be created
  + resource "libvirt_network" "esxi" {
      + addresses = [
          + "10.11.12.0/24",
        ]
      + bridge    = (known after apply)
      + domain    = "esxi.local"
      + id        = (known after apply)
      + mode      = "nat"
      + name      = "esxi"
    }

  # libvirt_pool.esxi will be created
  + resource "libvirt_pool" "esxi" {
      + allocation = (known after apply)
      + available  = (known after apply)
      + capacity   = (known after apply)
      + id         = (known after apply)
      + name       = "esxi"
      + path       = "/stor/esxi"
      + type       = "dir"
    }

  # libvirt_volume.esxi will be created
  + resource "libvirt_volume" "esxi" {
      + format = "qcow2"
      + id     = (known after apply)
      + name   = "esxi"
      + pool   = "esxi"
      + size   = (known after apply)
      + source = "./../../packer/esxi/output/packer-esxi.qcow2"
    }

Plan: 4 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes
libvirt_pool.esxi: Creating...
libvirt_network.esxi: Creating...
libvirt_pool.esxi: Creation complete after 5s [id=908287c8-29e9-4043-ad7d-9b9a106b0b4d]
libvirt_volume.esxi: Creating...
libvirt_network.esxi: Creation complete after 5s [id=c41ee69b-2272-463c-9778-7cc2976bf9e8]
libvirt_volume.esxi: Creation complete after 5s [id=/stor/esxi/esxi]
libvirt_domain.esxi: Creating...
libvirt_domain.esxi: Creation complete after 0s [id=5e073dc1-96d0-4971-bf6f-84275537da09]

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.
for RETRY in {1..69}; do \
    if (echo >/dev/tcp/10.11.12.69/22) &>/dev/null; then \
        break; \
    fi; \
    sleep 2; \
done && [[ "$RETRY" -gt 0 ]] \
&& cd /home/gublyn/_git/terraform-packer-esxi-example/terraform/guest/ && (terraform init && terraform apply)

Initializing the backend...

Initializing provider plugins...

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
esxi_guest.guest: Refreshing state... [id=1]

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # esxi_guest.guest will be created
  + resource "esxi_guest" "guest" {
      + boot_disk_size         = (known after apply)
      + disk_store             = "datastore1"
      + guest_name             = "guest"
      + guest_shutdown_timeout = (known after apply)
      + guest_startup_timeout  = (known after apply)
      + guestos                = (known after apply)
      + id                     = (known after apply)
      + ip_address             = (known after apply)
      + memsize                = (known after apply)
      + notes                  = (known after apply)
      + numvcpus               = (known after apply)
      + ovf_properties_timer   = 180
      + ovf_source             = "./../../downloads/bionic-server-cloudimg-amd64.ova"
      + power                  = "on"
      + resource_pool_name     = (known after apply)
      + virthwver              = (known after apply)

      + network_interfaces {
          + mac_address     = (known after apply)
          + nic_type        = (known after apply)
          + virtual_network = "VM Network"
        }

      + ovf_properties {
          + key   = "user-data"
          + value = "I2Nsb3VkLWNvbmZpZwpzc2hfcHdhdXRoOiBmYWxzZQp1c2VyczoKICAtIG5hbWU6ICJ1YnVudHUiCiAgICBzc2hfYXV0aG9yaXplZF9rZXlzOgogICAgICAtICJzc2gtZWQyNTUxOSBBQUFBQzNOemFDMWxaREkxTlRFNUFBQUFJSUdoR3lEeWsrallUNml4RGRvaGlpaGQ3L0laR2hHa2NRYTVyYVpCSnIxQyBndWJseW5AZmFybWVyIgogICAgc3VkbzoKICAgICAgLSAiQUxMPShBTEwpIE5PUEFTU1dEOkFMTCIKICAgIGdyb3VwczoKICAgICAgLSAic3VkbyIKICAgIHNoZWxsOiAiL2Jpbi9iYXNoIgogIC0gbmFtZTogInJvb3QiCiAgICBzc2hfYXV0aG9yaXplZF9rZXlzOgogICAgICAtICJzc2gtZWQyNTUxOSBBQUFBQzNOemFDMWxaREkxTlRFNUFBQUFJSUdoR3lEeWsrallUNml4RGRvaGlpaGQ3L0laR2hHa2NRYTVyYVpCSnIxQyBndWJseW5AZmFybWVyIgogICAgc2hlbGw6ICIvYmluL2Jhc2giCmNocGFzc3dkOgogIGxpc3Q6CiAgICAtICJ1YnVudHU6YXNkMTIzWCIKICBleHBpcmU6IGZhbHNlCndyaXRlX2ZpbGVzOgogIC0gY29udGVudDogfAogICAgICBbUmVzb2x2ZV0KICAgICAgRE5TPTguOC44LjgKICAgIHBhdGg6ICIvZXRjL3N5c3RlbWQvcmVzb2x2ZWQuY29uZi5kL2dvb2dsZS5jb25mIgpydW5jbWQ6CiAgLSBbInN5c3RlbWN0bCIsICJyZXN0YXJ0IiwgInN5c3RlbWQtcmVzb2x2ZWQuc2VydmljZSJdCg=="
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes
esxi_guest.guest: Creating...
esxi_guest.guest: Still creating... [10s elapsed]
esxi_guest.guest: Still creating... [20s elapsed]
esxi_guest.guest: Still creating... [30s elapsed]
esxi_guest.guest: Still creating... [40s elapsed]
esxi_guest.guest: Still creating... [50s elapsed]
esxi_guest.guest: Still creating... [1m0s elapsed]
esxi_guest.guest: Still creating... [1m10s elapsed]
esxi_guest.guest: Still creating... [1m20s elapsed]
esxi_guest.guest: Still creating... [1m30s elapsed]
esxi_guest.guest: Still creating... [1m40s elapsed]
esxi_guest.guest: Still creating... [1m50s elapsed]
esxi_guest.guest: Still creating... [2m0s elapsed]
esxi_guest.guest: Still creating... [2m10s elapsed]
esxi_guest.guest: Still creating... [2m20s elapsed]
esxi_guest.guest: Still creating... [2m30s elapsed]
esxi_guest.guest: Still creating... [2m40s elapsed]
esxi_guest.guest: Still creating... [2m50s elapsed]
esxi_guest.guest: Still creating... [3m0s elapsed]
esxi_guest.guest: Still creating... [3m10s elapsed]
esxi_guest.guest: Still creating... [3m20s elapsed]
esxi_guest.guest: Still creating... [3m30s elapsed]
esxi_guest.guest: Still creating... [3m40s elapsed]
esxi_guest.guest: Still creating... [3m50s elapsed]
esxi_guest.guest: Still creating... [4m0s elapsed]
esxi_guest.guest: Still creating... [4m10s elapsed]
esxi_guest.guest: Still creating... [4m20s elapsed]
esxi_guest.guest: Still creating... [4m30s elapsed]
esxi_guest.guest: Still creating... [4m40s elapsed]
esxi_guest.guest: Still creating... [4m50s elapsed]
esxi_guest.guest: Still creating... [5m0s elapsed]
esxi_guest.guest: Still creating... [5m10s elapsed]
esxi_guest.guest: Still creating... [5m20s elapsed]
esxi_guest.guest: Creation complete after 5m21s [id=1]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

ipv4 = 10.11.12.33
```

## 5. LOGIN INTO ESXI GUEST VM

```bash
gublyn:~/_git/terraform-packer-esxi-example$ ssh root@10.11.12.33
The authenticity of host '10.11.12.33 (10.11.12.33)' can't be established.
ECDSA key fingerprint is SHA256:yf48K2EFhXMTdfq4WaCnKf+iRPimQKOsfXSY9u1kbjY.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '10.11.12.33' (ECDSA) to the list of known hosts.
Welcome to Ubuntu 18.04.3 LTS (GNU/Linux 4.15.0-70-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Fri Nov 29 15:39:04 UTC 2019

  System load:  0.32              Processes:             100
  Usage of /:   10.1% of 9.52GB   Users logged in:       0
  Memory usage: 13%               IP address for ens192: 10.11.12.33
  Swap usage:   0%

0 packages can be updated.
0 updates are security updates.



The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

root@ubuntuguest:~# dmesg | grep VMware
[    0.000000] DMI: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 12/12/2018
[    0.000000] Hypervisor detected: VMware
[    0.000000] Booting paravirtualized kernel on VMware hypervisor
[    8.669627] ata2.00: ATAPI: VMware Virtual IDE CDROM Drive, 00000001, max UDMA/33
[    8.741238] scsi 1:0:0:0: CD-ROM            NECVMWar VMware IDE CDR10 1.00 PQ: 0 ANSI: 5
[    9.777969] VMware PVSCSI driver - version 1.0.7.0-k
[    9.860940] input: VirtualPS/2 VMware VMMouse as /devices/platform/i8042/serio1/input/input4
[    9.908471] input: VirtualPS/2 VMware VMMouse as /devices/platform/i8042/serio1/input/input3
[    9.951424] scsi host2: VMware PVSCSI storage adapter rev 2, req/cmp/msg rings: 8/8/1 pages, cmd_per_lun=254
[   10.006694] vmw_pvscsi 0000:03:00.0: VMware PVSCSI rev 2 host #2
[   10.055485] scsi 2:0:0:0: Direct-Access     VMware   Virtual disk     1.0  PQ: 0 ANSI: 2
```

## 6. THINK AGAIN... xD

[//]: # ( vim:set ts=2 sw=2 et syn=markdown: )
