#!/usr/bin/env bash
# QEMU, libvirt, UEFI firmware, the default network and pool. Safe to run again.
set -euo pipefail
# shellcheck source=/dev/null
. /etc/os-release
vsh() { sudo virsh -c qemu:///system "$@"; }   # sudo: a new group needs a new login

case " $ID ${ID_LIKE:-} " in
  *" debian "* | *" ubuntu "*)
    # Debian and Ubuntu
    sudo apt update
    sudo apt install -y qemu-system-x86 qemu-utils libvirt-daemon-system libvirt-clients ovmf
    sudo usermod -aG libvirt,kvm "$USER" ;;   # kvm: /dev/kvm is group-only here
  *" fedora "*)
    # Fedora
    sudo dnf install -y @virtualization edk2-ovmf
    sudo systemctl enable --now libvirtd
    sudo usermod -aG libvirt "$USER" ;;
  *) echo "Unknown distribution ($ID): install QEMU, libvirt and OVMF yourself." >&2; exit 1 ;;
esac

# Then log out and back in, so the new group applies.
# If libvirt's default network is not active, start it now and on every boot:
grep -q '^Active: *yes' <<<"$(vsh net-info default)" || vsh net-start default
vsh net-autostart default

# No "default" storage pool yet? Create it. The check fails if it is missing:
vsh pool-info default >/dev/null 2>&1 || {
  vsh pool-define-as default dir --target /var/lib/libvirt/images
  vsh pool-build default
}
grep -q '^State: *running' <<<"$(vsh pool-info default)" || vsh pool-start default
vsh pool-autostart default

echo "Done. Log out and back in so the libvirt group applies, then run setup/preflight.sh."
