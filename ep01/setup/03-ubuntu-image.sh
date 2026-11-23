# Download the Ubuntu 26.04 cloud image and its checksums
BASE=https://cloud-images.ubuntu.com/releases/26.04/release
sudo mkdir -p /var/lib/libvirt/images/base
cd /var/lib/libvirt/images/base
sudo curl -LO "$BASE/ubuntu-26.04-server-cloudimg-amd64.img"
sudo curl -LO "$BASE/SHA256SUMS"

# Verify the download. Expect: ubuntu-26.04-server-cloudimg-amd64.img: OK
sha256sum -c --ignore-missing SHA256SUMS
