# Setup (run once)

The commands shown on screen in episode 01. Read each script before running it.

1. `01-install-opentofu.sh`: three ways to install OpenTofu; pick one.
2. `02-install-libvirt.sh`: QEMU and libvirt on Debian/Ubuntu or Fedora, the `default` network, and the `default` storage pool if it is missing. Log out and back in after adding yourself to the `libvirt` group.
3. `03-ubuntu-image.sh`: downloads the Ubuntu 26.04 cloud image into `/var/lib/libvirt/images/base` and checks it against Ubuntu's SHA256SUMS. The lab's `base_image` variable points there.
