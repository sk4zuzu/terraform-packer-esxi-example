TERRAFORM-PACKER-ESXI-EXAMPLE
=============================

## 1. PURPOSE

Just a devops exercise.

## 2. FILES TO DOWNLOAD

```shell
~/_git/terraform-packer-esxi-example/files$ ls -1
bionic-server-cloudimg-amd64.ova
VMware-ovftool-4.3.0-15755677-lin.x86_64.bundle
VMware-VMvisor-Installer-6.7.0.update03-14320388.x86_64.iso
```

## 3. INSTALL PACKER, TERRAFORM AND OVFTOOL

```shell
~/_git/terraform-packer-esxi-example$ nix-shell --run 'make requirements'
make -f /stor/asd/_git/terraform-packer-esxi-example/Makefile.BINARIES
make[1]: Entering directory '/stor/asd/_git/terraform-packer-esxi-example'
install -d /tmp/packer-1.7.8/ && curl -fSL https://releases.hashicorp.com/packer/1.7.8/packer_1.7.8_linux_amd64.zip -o /tmp/packer-1.7.8/download.zip && unzip -o -d /tmp/packer-1.7.8/ /tmp/packer-1.7.8/download.zip && mv /tmp/packer-1.7.8/packer* /stor/asd/_git/terraform-packer-esxi-example/bin/packer-1.7.8 && rm -rf /tmp/packer-1.7.8/ && chmod +x /stor/asd/_git/terraform-packer-esxi-example/bin/packer-1.7.8
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 30.3M  100 30.3M    0     0  2189k      0  0:00:14  0:00:14 --:--:-- 2220k
Archive:  /tmp/packer-1.7.8/download.zip
  inflating: /tmp/packer-1.7.8/packer
rm -f /stor/asd/_git/terraform-packer-esxi-example/bin/packer && ln -s /stor/asd/_git/terraform-packer-esxi-example/bin/packer-1.7.8 /stor/asd/_git/terraform-packer-esxi-example/bin/packer
install -d /tmp/terraform-1.1.3/ && curl -fSL https://releases.hashicorp.com/terraform/1.1.3/terraform_1.1.3_linux_amd64.zip -o /tmp/terraform-1.1.3/download.zip && unzip -o -d /tmp/terraform-1.1.3/ /tmp/terraform-1.1.3/download.zip && mv /tmp/terraform-1.1.3/terraform* /stor/asd/_git/terraform-packer-esxi-example/bin/terraform-1.1.3 && rm -rf /tmp/terraform-1.1.3/ && chmod +x /stor/asd/_git/terraform-packer-esxi-example/bin/terraform-1.1.3
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 17.8M  100 17.8M    0     0  2086k      0  0:00:08  0:00:08 --:--:-- 2060k
Archive:  /tmp/terraform-1.1.3/download.zip
  inflating: /tmp/terraform-1.1.3/terraform
rm -f /stor/asd/_git/terraform-packer-esxi-example/bin/terraform && ln -s /stor/asd/_git/terraform-packer-esxi-example/bin/terraform-1.1.3 /stor/asd/_git/terraform-packer-esxi-example/bin/terraform
make[1]: Leaving directory '/stor/asd/_git/terraform-packer-esxi-example'
make -f /stor/asd/_git/terraform-packer-esxi-example/Makefile.OVFTOOL
make[1]: Entering directory '/stor/asd/_git/terraform-packer-esxi-example'
docker build -t ovftool-extractor -f- /stor/asd/_git/terraform-packer-esxi-example/ <<< "$DOCKERFILE"
Sending build context to Docker daemon  2.462GB
Step 1/5 : FROM ubuntu:18.04
 ---> 886eca19e611
Step 2/5 : COPY /files/VMware-ovftool-4.3.0-15755677-lin.x86_64.bundle /tmp/installer.sh
 ---> Using cache
 ---> e6eac9653336
Step 3/5 : RUN chmod +x /tmp/installer.sh && /tmp/installer.sh --eulas-agreed
 ---> Using cache
 ---> 83bb50e0ffa8
Step 4/5 : ENTRYPOINT []
 ---> Using cache
 ---> 779d2292cd93
Step 5/5 : CMD cp -R /usr/lib/vmware-ovftool/* /ovftool/ && exec chown -R 1000:1 /ovftool/
 ---> Using cache
 ---> 1639842b1b39
Successfully built 1639842b1b39
Successfully tagged ovftool-extractor:latest
docker run -v /stor/asd/_git/terraform-packer-esxi-example/ovftool/:/ovftool/ --rm -t ovftool-extractor
sed -i "1s:#!/bin/bash:#!/usr/bin/env bash:" /stor/asd/_git/terraform-packer-esxi-example/ovftool/ovftool
patchelf --set-interpreter /nix/store/z56jcx3j1gfyk4sv7g8iaan0ssbdkhz1-glibc-2.33-56/lib/ld-linux-x86-64.so.2 /stor/asd/_git/terraform-packer-esxi-example/ovftool/ovftool.bin
rm /stor/asd/_git/terraform-packer-esxi-example/bin/ovftool
rm: cannot remove '/stor/asd/_git/terraform-packer-esxi-example/bin/ovftool': No such file or directory
make[1]: [/stor/asd/_git/terraform-packer-esxi-example/Makefile.OVFTOOL:29: /stor/asd/_git/terraform-packer-esxi-example/bin/ovftool] Error 1 (ignored)
ln -s /stor/asd/_git/terraform-packer-esxi-example/ovftool/ovftool /stor/asd/_git/terraform-packer-esxi-example/bin/ovftool
make[1]: Leaving directory '/stor/asd/_git/terraform-packer-esxi-example'
```

## 4. BUILD ESXI IMAGE, DEPLOY ESXI HYPERVISOR, DEPLOY SINGLE UBUNTU GUEST VM

```shell
~/_git/terraform-packer-esxi-example$ nix-shell --run 'PACKER_NO_COLOR=1 TF_CLI_ARGS=-no-color make'
cd /stor/asd/_git/terraform-packer-esxi-example/packer/esxi/ && make build
make[1]: Entering directory '/stor/asd/_git/terraform-packer-esxi-example/packer/esxi'
install -d /stor/asd/_git/terraform-packer-esxi-example/packer/esxi/.cache/
if ! [[ -e /stor/asd/_git/terraform-packer-esxi-example/packer/esxi/.cache/build.pkr.hcl ]]; then ln -s /dev/stdin /stor/asd/_git/terraform-packer-esxi-example/packer/esxi/.cache/build.pkr.hcl; fi
/stor/asd/_git/terraform-packer-esxi-example/packer/esxi/../../bin/packer build -force /stor/asd/_git/terraform-packer-esxi-example/packer/esxi/.cache/build.pkr.hcl <<< "$PACKERFILE"
qemu.esxi: output will be in this color.

==> qemu.esxi: Retrieving ISO
==> qemu.esxi: Trying file:///stor/asd/_git/terraform-packer-esxi-example/packer/esxi/../../files/VMware-VMvisor-Installer-6.7.0.update03-14320388.x86_64.iso
==> qemu.esxi: Trying file:///stor/asd/_git/terraform-packer-esxi-example/packer/esxi/../../files/VMware-VMvisor-Installer-6.7.0.update03-14320388.x86_64.iso?checksum=sha256%3Afcbaa4cd952abd9e629fb131b8f46a949844405d8976372e7e5b55917623fbe0
==> qemu.esxi: file:///stor/asd/_git/terraform-packer-esxi-example/packer/esxi/../../files/VMware-VMvisor-Installer-6.7.0.update03-14320388.x86_64.iso?checksum=sha256%3Afcbaa4cd952abd9e629fb131b8f46a949844405d8976372e7e5b55917623fbe0 => /stor/asd/_git/terraform-packer-esxi-example/files/VMware-VMvisor-Installer-6.7.0.update03-14320388.x86_64.iso
==> qemu.esxi: Starting HTTP server on port 8087
    qemu.esxi: No communicator is set; skipping port forwarding setup.
==> qemu.esxi: Looking for available port between 5900 and 6000 on 127.0.0.1
==> qemu.esxi: Starting VM, booting from CD-ROM
    qemu.esxi: The VM will be run headless, without a GUI. If you want to
    qemu.esxi: view the screen of the VM, connect via VNC without a password to
    qemu.esxi: vnc://127.0.0.1:5940
==> qemu.esxi: Overriding default Qemu arguments with qemuargs template option...
==> qemu.esxi: Waiting 10s for boot...
==> qemu.esxi: Connecting to VM via VNC (127.0.0.1:5940)
==> qemu.esxi: Typing the boot command over VNC...
    qemu.esxi: No communicator is configured -- skipping StepWaitGuestAddress
==> qemu.esxi: Waiting for shutdown...
==> qemu.esxi: Converting hard drive...
Build 'qemu.esxi' finished after 3 minutes 7 seconds.

==> Wait completed after 3 minutes 7 seconds

==> Builds finished. The artifacts of successful builds are:
--> qemu.esxi: VM files in directory: /stor/asd/_git/terraform-packer-esxi-example/packer/esxi/.cache/output/
make[1]: Leaving directory '/stor/asd/_git/terraform-packer-esxi-example/packer/esxi'
cd /stor/asd/_git/terraform-packer-esxi-example/terraform/esxi/ && (/stor/asd/_git/terraform-packer-esxi-example/bin/terraform init && /stor/asd/_git/terraform-packer-esxi-example/bin/terraform apply)

Initializing the backend...

Initializing provider plugins...
- Finding dmacvicar/libvirt versions matching "0.6.12"...
- Installing dmacvicar/libvirt v0.6.12...
- Installed dmacvicar/libvirt v0.6.12 (self-signed, key ID 96B1FE1A8D4E1EAB)

Partner and community providers are signed by their developers.
If you'd like to know more about provider signing, you can read about it here:
https://www.terraform.io/docs/cli/plugins/signing.html

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # libvirt_domain.esxi will be created
  + resource "libvirt_domain" "esxi" {
      + arch        = (known after apply)
      + disk        = [
          + {
              + block_device = null
              + file         = null
              + scsi         = null
              + url          = null
              + volume_id    = (known after apply)
              + wwn          = null
            },
        ]
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

      + cpu {
          + mode = "host-passthrough"
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
          + xslt = <<-EOT
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
            EOT
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
      + source = "./../../packer/esxi/.cache/output/packer-esxi.qcow2"
    }

Plan: 4 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes
libvirt_pool.esxi: Creating...
libvirt_network.esxi: Creating...
libvirt_pool.esxi: Creation complete after 6s [id=75c66e20-d549-4ab3-8cd4-82c71eae41ea]
libvirt_volume.esxi: Creating...
libvirt_network.esxi: Creation complete after 6s [id=3dccca32-351b-452d-ad20-efa033587e24]
libvirt_volume.esxi: Creation complete after 0s [id=/stor/esxi/esxi]
libvirt_domain.esxi: Creating...
libvirt_domain.esxi: Creation complete after 1s [id=f766df7b-dd00-4ced-bcf4-4bf8a8ebafaa]

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.
for RETRY in {1..69}; do \
    if (echo >/dev/tcp/10.11.12.69/22) &>/dev/null; then \
        break; \
    fi; \
    sleep 2; \
done && [[ "$RETRY" -gt 0 ]]
cd /stor/asd/_git/terraform-packer-esxi-example/terraform/guest/ && (/stor/asd/_git/terraform-packer-esxi-example/bin/terraform init && /stor/asd/_git/terraform-packer-esxi-example/bin/terraform apply)

Initializing the backend...

Initializing provider plugins...
- Finding josenk/esxi versions matching "1.10.0"...
- Installing josenk/esxi v1.10.0...
- Installed josenk/esxi v1.10.0 (self-signed, key ID A3C2BB2C490C3920)

Partner and community providers are signed by their developers.
If you'd like to know more about provider signing, you can read about it here:
https://www.terraform.io/docs/cli/plugins/signing.html

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

Terraform used the selected providers to generate the following execution
plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # esxi_guest.guest will be created
  + resource "esxi_guest" "guest" {
      + boot_disk_size         = (known after apply)
      + boot_disk_type         = "thin"
      + boot_firmware          = "bios"
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
      + ovf_source             = "./../../files/bionic-server-cloudimg-amd64.ova"
      + power                  = (known after apply)
      + resource_pool_name     = "/"
      + virthwver              = (known after apply)

      + network_interfaces {
          + mac_address     = (known after apply)
          + nic_type        = (known after apply)
          + virtual_network = "VM Network"
        }

      + ovf_properties {
          + key   = "user-data"
          + value = "I2Nsb3VkLWNvbmZpZwpzc2hfcHdhdXRoOiBmYWxzZQp1c2VyczoKICAtIG5hbWU6ICJ1YnVudHUiCiAgICBzc2hfYXV0aG9yaXplZF9rZXlzOgogICAgICAtICJzc2gtcnNhIEFBQUFCM056YUMxeWMyRUFBQUFEQVFBQkFBQUNBUUN5YVhrUHRNV1Fwbk9hNE01NDR6NTlNczU5R1k3UDgrUTdhRkVZbmtwM0F2UkxuWVZYbWxqRHcxc0I1NnBYdDVxeEI3RVZ5clBKS2RnaVBSWFpWTXhPT1czbnJuNVRkU1FMc0hvekNnMUZ6LzdNZ3BxQnRENkhMQ2xrM2wvRXVwR0VZbXFhYWF4U1NCazlGV01rVlNKTzBSSkF1cENRMjE1YzVRNHZqNUY2QlZwcy8yNHZZdm03NWk1clpJVkVLQzVxd2dNQ0E4R3RIZEFMQ2dxUXNrNHNxVFBZeVB2cDQwOVRQZzVwWG1XbzQwcjAyOVZxZ0FwZXpMWUdUdnZPdzArSEZhb05XNGw4N3ZCNkplQ0VQaU5sUUlTR0JEMTl3bHJwS2J1YkZKNG5PeVB4Uk50ZVIrMldkS3pPVnFvMUdlM2xoMDFwbjRTMStldFo5Ylo3Vm0vSzNuYXBSODNLOW10RzllQlJiV0RQY1Z0M1R1UkFyRU9UTWROOVJSaGdIMlFQeDVnRzRicVZzcGlxZjc5dU5FTjNqa3B6Slk5ZlJHZDlFeUtOTzgxcGVqWGZyQlpmK29nNjJnNGR5aGJ1YlBqRzlRL0x4RVcxVVNFVEs3WFBKR0hJNVh2aEpMa0NmWUorUXpUMFk5THp0aEc5Z2IvOHFoaXM1VStBZHIzU2x4eHY1MS90SlFwbkN1Um4rNmNJR2QwTUJGMnFUZmdQU290cHd1SGRSWHJaTC9KTVQ3aER0VTR0Zm5oSURaRlB0VTE0NzRWcWRvejRSWUZEbzJDUkVNMWlHZ29mZWUwa2t4Ni9KZTlSOXVtSEVNS2ZyRnVtUUJBaXRNS0FLS0JHRHNMd0puWkxXRklxUnpKWEx6Q1l5UHBaQk0yTFk0VzBJUWU1QUNCeEVlTVRwUT09IGFzZEByZXB0aSIKICAgIHN1ZG86CiAgICAgIC0gIkFMTD0oQUxMKSBOT1BBU1NXRDpBTEwiCiAgICBncm91cHM6CiAgICAgIC0gInN1ZG8iCiAgICBzaGVsbDogIi9iaW4vYmFzaCIKICAtIG5hbWU6ICJyb290IgogICAgc3NoX2F1dGhvcml6ZWRfa2V5czoKICAgICAgLSAic3NoLXJzYSBBQUFBQjNOemFDMXljMkVBQUFBREFRQUJBQUFDQVFDeWFYa1B0TVdRcG5PYTRNNTQ0ejU5TXM1OUdZN1A4K1E3YUZFWW5rcDNBdlJMbllWWG1sakR3MXNCNTZwWHQ1cXhCN0VWeXJQSktkZ2lQUlhaVk14T09XM25ybjVUZFNRTHNIb3pDZzFGei83TWdwcUJ0RDZITENsazNsL0V1cEdFWW1xYWFheFNTQms5RldNa1ZTSk8wUkpBdXBDUTIxNWM1UTR2ajVGNkJWcHMvMjR2WXZtNzVpNXJaSVZFS0M1cXdnTUNBOEd0SGRBTENncVFzazRzcVRQWXlQdnA0MDlUUGc1cFhtV280MHIwMjlWcWdBcGV6TFlHVHZ2T3cwK0hGYW9OVzRsODd2QjZKZUNFUGlObFFJU0dCRDE5d2xycEtidWJGSjRuT3lQeFJOdGVSKzJXZEt6T1ZxbzFHZTNsaDAxcG40UzErZXRaOWJaN1ZtL0szbmFwUjgzSzltdEc5ZUJSYldEUGNWdDNUdVJBckVPVE1kTjlSUmhnSDJRUHg1Z0c0YnFWc3BpcWY3OXVORU4zamtwekpZOWZSR2Q5RXlLTk84MXBlalhmckJaZitvZzYyZzRkeWhidWJQakc5US9MeEVXMVVTRVRLN1hQSkdISTVYdmhKTGtDZllKK1F6VDBZOUx6dGhHOWdiLzhxaGlzNVUrQWRyM1NseHh2NTEvdEpRcG5DdVJuKzZjSUdkME1CRjJxVGZnUFNvdHB3dUhkUlhyWkwvSk1UN2hEdFU0dGZuaElEWkZQdFUxNDc0VnFkb3o0UllGRG8yQ1JFTTFpR2dvZmVlMGtreDYvSmU5Ujl1bUhFTUtmckZ1bVFCQWl0TUtBS0tCR0RzTHdKblpMV0ZJcVJ6SlhMekNZeVBwWkJNMkxZNFcwSVFlNUFDQnhFZU1UcFE9PSBhc2RAcmVwdGkiCiAgICBzaGVsbDogIi9iaW4vYmFzaCIKY2hwYXNzd2Q6CiAgbGlzdDoKICAgIC0gInVidW50dTphc2QxMjNYIgogIGV4cGlyZTogZmFsc2UKd3JpdGVfZmlsZXM6CiAgLSBjb250ZW50OiB8CiAgICAgIFtSZXNvbHZlXQogICAgICBETlM9OC44LjguOAogICAgcGF0aDogIi9ldGMvc3lzdGVtZC9yZXNvbHZlZC5jb25mLmQvZ29vZ2xlLmNvbmYiCnJ1bmNtZDoKICAtIFsic3lzdGVtY3RsIiwgInJlc3RhcnQiLCAic3lzdGVtZC1yZXNvbHZlZC5zZXJ2aWNlIl0K"
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + ipv4 = (known after apply)

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
esxi_guest.guest: Creation complete after 5m6s [id=1]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

ipv4 = "10.11.12.214"
```

## 5. LOGIN INTO ESXI GUEST VM

```shell
~/_git/terraform-packer-esxi-example$ ssh root@10.11.12.214
The authenticity of host '10.11.12.214 (10.11.12.214)' can't be established.
ED25519 key fingerprint is SHA256:zrQX1hdnZwXPtucDqI922ZEViLmFYLZLqJ1RCOA5CHM.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '10.11.12.214' (ED25519) to the list of known hosts.
Welcome to Ubuntu 18.04.6 LTS (GNU/Linux 4.15.0-166-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Sat Jan  8 18:45:04 UTC 2022

  System load:  0.11              Processes:             102
  Usage of /:   11.1% of 9.52GB   Users logged in:       0
  Memory usage: 13%               IP address for ens192: 10.11.12.214
  Swap usage:   0%

0 updates can be applied immediately.



The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

root@ubuntuguest:~# dmesg | grep VMware
[    0.000000] DMI: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 12/12/2018
[    0.000000] Hypervisor detected: VMware
[    0.000000] Booting paravirtualized kernel on VMware hypervisor
[    3.984665] ata2.00: ATAPI: VMware Virtual IDE CDROM Drive, 00000001, max UDMA/33
[    4.039994] scsi 1:0:0:0: CD-ROM            NECVMWar VMware IDE CDR10 1.00 PQ: 0 ANSI: 5
[    4.473711] VMware PVSCSI driver - version 1.0.7.0-k
[    4.524319] scsi host2: VMware PVSCSI storage adapter rev 2, req/cmp/msg rings: 8/8/1 pages, cmd_per_lun=254
[    4.548208] vmw_pvscsi 0000:03:00.0: VMware PVSCSI rev 2 host #2
[    4.556268] input: VirtualPS/2 VMware VMMouse as /devices/platform/i8042/serio1/input/input4
[    4.575129] scsi 2:0:0:0: Direct-Access     VMware   Virtual disk     1.0  PQ: 0 ANSI: 2
[    4.577644] input: VirtualPS/2 VMware VMMouse as /devices/platform/i8042/serio1/input/input3
```
