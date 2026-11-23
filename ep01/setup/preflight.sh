#!/usr/bin/env bash
# shellcheck disable=SC2016  # fix lines print $USER literally, for the reader to run
# Episode 01 preflight: one read-only line per prerequisite. No sudo, changes nothing.
# Run it from the ep01 folder:  setup/preflight.sh      Exit 0 = all ok, 1 = something failed.
# The paths and limits below can be overridden (for testing the FAIL lines), for example:
#   PREFLIGHT_MIN_MEM_GIB=9999 setup/preflight.sh
set -uo pipefail

KVM=${PREFLIGHT_KVM:-/dev/kvm}
URI=${PREFLIGHT_URI:-qemu:///system}
NET=${PREFLIGHT_NET:-default}
POOL=${PREFLIGHT_POOL:-default}
MIN_MEM_GIB=${PREFLIGHT_MIN_MEM_GIB:-4}
MIN_DISK_GIB=${PREFLIGHT_MIN_DISK_GIB:-15}
IMAGE=${PREFLIGHT_IMAGE:-/var/lib/libvirt/images/base/ubuntu-26.04-server-cloudimg-amd64.img}
TOOLS=${PREFLIGHT_TOOLS:-tofu curl ssh ssh-keygen}
MIN_TOFU=${PREFLIGHT_MIN_TOFU:-1.13}

failed=0
total=0
row() { # row <check> <ok|FAIL> <fact> [fix]
  total=$((total + 1))
  printf '%-5s %-8s %s\n' "$2" "$1" "$3"
  if [ "$2" != ok ]; then
    failed=$((failed + 1))
    printf '      fix: %s\n' "$4"
  fi
}
virsh_q() { timeout 15 virsh -c "$URI" "$@" 2>/dev/null; }

echo "Preflight for the ep01 lab"

# kvm
if [ -c "$KVM" ] && [ -r "$KVM" ] && [ -w "$KVM" ]; then
  row kvm ok "$KVM is usable"
elif [ -e "$KVM" ]; then
  row kvm FAIL "$KVM exists, but you cannot read and write it" 'sudo adduser $USER kvm, then log in again'
else
  row kvm FAIL "$KVM is missing" "enable VT-x/SVM Mode in BIOS/UEFI, then reboot"
fi

# group
if [[ " $(id -nG) " == *" libvirt "* ]]; then
  row group ok "you are a member"
else
  row group FAIL "you are not a member of the libvirt group" 'sudo adduser $USER libvirt (or usermod -aG libvirt $USER), log in again'
fi

# libvirt
if ver=$(virsh_q version | sed -n 's/^Using library: libvirt //p' | head -n 1) && [ -n "$ver" ]; then
  row libvirt ok "virsh reaches $URI (libvirt $ver)"
else
  row libvirt FAIL "virsh cannot reach $URI" "see setup/02-install-libvirt.sh"
fi

# network
net_info=$(virsh_q net-info "$NET")   # captured first: grep -q ends a pipe early and pipefail would flag it
if grep -Eq '^Active:[[:space:]]+yes' <<<"$net_info"; then
  row network ok "$NET is active"
else
  row network FAIL "libvirt network $NET is not active" "see setup/02-install-libvirt.sh"
fi

# pool
pool_info=$(virsh_q pool-info "$POOL")
if grep -Eq '^State:[[:space:]]+running' <<<"$pool_info"; then
  row pool ok "$POOL is active"
else
  row pool FAIL "storage pool $POOL is not active" "see setup/02-install-libvirt.sh"
fi

# memory
mem_kb=$(awk '/^MemAvailable:/ {print $2}' /proc/meminfo 2>/dev/null)
mem_gib=$(( ${mem_kb:-0} / 1048576 ))
if [ "$mem_gib" -ge "$MIN_MEM_GIB" ]; then
  row memory ok "$mem_gib GiB available (need $MIN_MEM_GIB)"
else
  row memory FAIL "$mem_gib GiB available (need $MIN_MEM_GIB)" "close programs, or use a machine with more memory"
fi

# disk: free space where the pool keeps its volumes
pool_path=$(virsh_q pool-dumpxml "$POOL" | sed -n 's|.*<path>\(.*\)</path>.*|\1|p' | head -n 1)
pool_path=${PREFLIGHT_POOL_PATH:-${pool_path:-/var/lib/libvirt/images}}
disk_gib=$(df -P -BG "$pool_path" 2>/dev/null | awk 'NR==2 {gsub("G","",$4); print $4}')
if [ "${disk_gib:-0}" -ge "$MIN_DISK_GIB" ]; then
  row disk ok "$disk_gib GiB free in $pool_path (need $MIN_DISK_GIB)"
else
  row disk FAIL "${disk_gib:-0} GiB free in $pool_path (need $MIN_DISK_GIB)" "free space on the disk that holds $pool_path"
fi

# tools
missing=""
for t in $TOOLS; do command -v "$t" >/dev/null 2>&1 || missing="$missing $t"; done
tofu_ver=""
if command -v tofu >/dev/null 2>&1; then
  tofu_ver=$(tofu version 2>/dev/null | sed -n '1s/^OpenTofu v//p')
fi
if [ -n "$missing" ]; then
  row tools FAIL "missing:$missing" "install the missing tool (OpenTofu: setup/01-install-opentofu.sh)"
elif [ -n "$tofu_ver" ] && [ "$(printf '%s\n%s\n' "$MIN_TOFU" "$tofu_ver" | sort -V | head -n 1)" != "$MIN_TOFU" ]; then
  row tools FAIL "tofu $tofu_ver is older than $MIN_TOFU" "install a newer OpenTofu: setup/01-install-opentofu.sh"
else
  row tools ok "tofu ${tofu_ver:-?}, curl, ssh, ssh-keygen"
fi

# image: checksum against Ubuntu's SHA256SUMS, kept next to the image
img_dir=$(dirname "$IMAGE")
img_name=$(basename "$IMAGE")
if [ -r "$IMAGE" ] && [ -r "$img_dir/SHA256SUMS" ] \
  && sums=$(cd "$img_dir" && sha256sum -c --ignore-missing SHA256SUMS 2>/dev/null) \
  && grep -Fxq "$img_name: OK" <<<"$sums"; then
  row image ok "Ubuntu 26.04 image matches SHA256SUMS"
else
  row image FAIL "image missing or checksum does not match" "run setup/03-ubuntu-image.sh"
fi

if [ "$failed" -eq 0 ]; then
  echo "All $total checks passed."
else
  if [ "$failed" -eq 1 ]; then echo "1 check failed."; else echo "$failed checks failed."; fi
fi
[ "$failed" -eq 0 ]
