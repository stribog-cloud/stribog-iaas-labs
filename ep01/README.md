# Episode 01 lab: provision, verify, destroy a VM

Builds one Ubuntu 26.04 VM (2 vCPU, 2 GiB RAM, 10 GiB disk) with OpenTofu and
libvirt/KVM, installs nginx with cloud-init, checks it, then destroys it.

## First: run the preflight
After cloning, from this folder:
```sh
setup/preflight.sh
```
One line per check, `ok` or `FAIL` with the fix. Read-only. Fix every `FAIL` before going on.

## Prerequisites

- Linux host with KVM and libvirt running (`virsh -c qemu:///system list` works for your user)
- [OpenTofu](https://opentofu.org) 1.13 or newer
- An Ubuntu 26.04 cloud image on the host. Set `base_image` in `variables.tf`
  (or `-var base_image=...`) to its path.
- libvirt's `default` NAT network and `default` storage pool, both active
- UEFI firmware for QEMU (`ovmf` on Debian/Ubuntu, `edk2-ovmf` on Fedora): the VM boots with `firmware = "efi"`

`setup/02-install-libvirt.sh` installs the libvirt side of this; `setup/preflight.sh` checks it.

## Run it

```sh
ssh-keygen -t ed25519 -N '' -f lab_key        # throwaway key for this lab only
tofu init                                       # downloads the libvirt provider, writes .terraform.lock.hcl
tofu plan
tofu apply                                      # type yes; about a minute
./verify.sh "$(tofu output -raw vm_ip)"         # ssh, cloud-init, nginx, curl
tofu test                                       # optional: plan-only checks
```

The lock file is not shipped on purpose: you see `tofu init` create it, as in the video. In your own projects, commit `.terraform.lock.hcl`.

## Clean up

```sh
tofu destroy
virsh list --all          # no ep01-web
virsh vol-list default    # no ep01-disk.qcow2 or ep01-init.iso
```

Everything this lab creates is named `ep01-*`, and `tofu destroy` removes all of it.
