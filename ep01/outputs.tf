output "vm_ip" {
  description = "IPv4 address of the VM"
  value = one([
    for a in flatten(data.libvirt_domain_interface_addresses.web.interfaces[*].addrs) : a.addr
    if a.type == "ipv4"
  ])
}
