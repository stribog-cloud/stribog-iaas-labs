# vm.sh: a tiny helper for the lab. Load it with:  source vm.sh
# Then  vm <command>  runs that command on the VM, over ssh.
# Needs: the VM's address in $ip, the key file lab_key in this folder.
# Works in bash and zsh. Run it from the lab folder.

vm() {
  # -i lab_key                   log in with the private key we generated
  # StrictHostKeyChecking=no     do not ask "are you sure?" on first connect
  # UserKnownHostsFile=/dev/null do not save the host key (the VM is throwaway)
  # LogLevel=ERROR               hide the "Permanently added" warning
  # These host-key options are fine for a throwaway lab, never for real servers.
  ssh -i lab_key \
    -o StrictHostKeyChecking=no \
    -o UserKnownHostsFile=/dev/null \
    -o LogLevel=ERROR \
    "stribog@$ip" "$@"
}
