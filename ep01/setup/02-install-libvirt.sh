# Debian and Ubuntu
sudo apt update
sudo apt install -y qemu-system-x86 qemu-utils libvirt-daemon-system libvirt-clients
sudo adduser "$USER" libvirt

# Fedora
sudo dnf install -y @virtualization
sudo systemctl enable --now libvirtd
sudo usermod -aG libvirt "$USER"

# Then log out and back in, so the new group applies.
# If libvirt's default network is not active, start it now and on every boot:
sudo virsh net-start default
sudo virsh net-autostart default

# No "default" storage pool yet? Create it. The check fails if it is missing:
sudo virsh pool-info default >/dev/null 2>&1 || {
  sudo virsh pool-define-as default dir --target /var/lib/libvirt/images
  sudo virsh pool-build default
  sudo virsh pool-start default
  sudo virsh pool-autostart default
}
