# Plan-only checks: no VM is created.
run "vm_shape" {
  command = plan

  assert {
    condition     = libvirt_domain.web.vcpu == 2 && libvirt_domain.web.memory == 2048
    error_message = "VM must have 2 vCPU and 2 GiB RAM"
  }

  assert {
    condition     = startswith(libvirt_domain.web.name, "ep01-")
    error_message = "Every object name must start with ep01-"
  }
}
