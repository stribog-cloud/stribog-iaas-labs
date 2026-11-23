# Episode 01 lab: provision, verify, destroy a VM

Builds one Ubuntu 26.04 VM (2 vCPU, 2 GiB RAM, 10 GiB disk) with OpenTofu and
libvirt/KVM, installs nginx with cloud-init, checks it, then destroys it.

## Prerequisites

- Linux host with KVM and libvirt running (`virsh -c qemu:///system list` works for your user)
- [OpenTofu](https://opentofu.org) 1.13 or newer
- An Ubuntu 26.04 cloud image on the host. Set `base_image` in `variables.tf`
  (or `-var base_image=...`) to its path.
- libvirt's `default` NAT network and `default` storage pool, both active

## Run it

```sh
ssh-keygen -t ed25519 -N '' -f lab_key        # throwaway key for this lab only
tofu init                                       # downloads the libvirt provider
tofu plan
tofu apply                                      # type yes; about a minute
./verify.sh "$(tofu output -raw vm_ip)"         # ssh, cloud-init, nginx, curl
tofu test                                       # optional: plan-only checks
```

## Clean up

```sh
tofu destroy
virsh list --all          # no ep01-web
virsh vol-list default    # no ep01-disk.qcow2 or ep01-init.iso
```

Everything this lab creates is named `ep01-*`, and `tofu destroy` removes all of it.
