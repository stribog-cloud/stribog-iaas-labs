# Setup (run once)

The commands shown on screen in episode 01. Read each script before running it.

**Start here:** `setup/preflight.sh` (from the `ep01` folder). It checks KVM, the libvirt group, libvirt, the `default` network and pool, memory, disk, tools, UEFI firmware (OVMF) and the image, one line each, and prints the fix for any line that fails. It only reads; it changes nothing.

1. `01-install-opentofu.sh`: three ways to install OpenTofu; pick one.
2. `02-install-libvirt.sh`: runs as is (`setup/02-install-libvirt.sh`, asks for sudo) and picks apt or dnf from `/etc/os-release`. Installs QEMU, libvirt and OVMF (UEFI firmware, needed because `main.tf` boots with `firmware = "efi"`), adds you to the `libvirt` group (on Debian/Ubuntu also `kvm`), starts the `default` network and creates the `default` storage pool if needed. Safe to run again. Then log out and back in, so the groups apply.
3. `03-ubuntu-image.sh`: downloads the Ubuntu 26.04 cloud image into `/var/lib/libvirt/images/base` and checks it against Ubuntu's SHA256SUMS. The lab's `base_image` variable points there.
4. `preflight.sh`: run it first, and again after any fix. Exit code 0 means every check passed.
