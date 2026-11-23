#!/usr/bin/env bash
# Usage: ./verify.sh <vm-ip>   Checks the VM from the outside (the same checks as the video).
set -uo pipefail
ip="${1:?usage: verify.sh <vm-ip>}"
cd "$(dirname "$0")"        # vm.sh and lab_key live in this folder
source ./vm.sh              # defines vm(): ssh to the VM, uses $ip
fail=0

check() { # check <label> <command...>
  local label=$1; shift
  if out=$("$@" 2>&1); then echo "PASS  $label"; [ -n "$out" ] && echo "      $out"
  else echo "FAIL  $label"; echo "      $out"; fail=1; fi
}

# The VM boots before ssh answers: retry for up to 2 minutes.
for _ in $(seq 24); do vm true 2>/dev/null && break; sleep 5; done

check "cloud-init finished" vm cloud-init status --wait
check "nginx is active"     vm systemctl is-active nginx
check "web page says hello" bash -c "curl -fs http://$ip | grep -o 'Hello from Stribog episode 01'"

if [ "$fail" -eq 0 ]; then echo "RESULT: PASS"; else echo "RESULT: FAIL"; exit 1; fi
