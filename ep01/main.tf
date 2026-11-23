# The VM disk: a thin 10 GiB layer on top of the read-only Ubuntu image.
resource "libvirt_volume" "disk" {
  name     = "${var.name}-disk.qcow2"
  pool     = "default"
  capacity = 10 * 1024 * 1024 * 1024
  target   = { format = { type = "qcow2" } }

  backing_store = {
    path   = var.base_image
    format = { type = "qcow2" }
  }
}

# cloud-init settings, packed into a small ISO that the VM reads on first boot.
resource "libvirt_cloudinit_disk" "init" {
  name = "${var.name}-init"

  user_data = templatefile("${path.module}/cloud-init.yaml", {
    ssh_public_key = trimspace(file("${path.module}/${var.ssh_public_key_file}"))
  })
  meta_data = yamlencode({
    instance-id    = var.name
    local-hostname = var.name
  })
}

resource "libvirt_volume" "init" {
  name = "${var.name}-init.iso"
  pool = "default"

  create = { content = { url = libvirt_cloudinit_disk.init.path } }
}

# The virtual machine: 2 vCPU, 2 GiB RAM, on the default NAT network.
resource "libvirt_domain" "web" {
  name        = "${var.name}-web"
  type        = "kvm"
  vcpu        = 2
  memory      = 2048
  memory_unit = "MiB"
  running     = true

  # Give the guest the host's CPU features, and boot with UEFI (q35 + ACPI).
  cpu      = { mode = "host-passthrough" }
  features = { acpi = true }

  os = {
    type         = "hvm"
    type_arch    = "x86_64"
    type_machine = "q35"
    firmware     = "efi"
  }

  devices = {
    disks = [
      {
        source = { volume = { pool = libvirt_volume.disk.pool, volume = libvirt_volume.disk.name } }
        target = { dev = "vda", bus = "virtio" }
        driver = { type = "qcow2" }
      },
      {
        device = "cdrom"
        source = { volume = { pool = libvirt_volume.init.pool, volume = libvirt_volume.init.name } }
        target = { dev = "sda", bus = "sata" }
      },
    ]

    interfaces = [
      {
        type   = "network"
        model  = { type = "virtio" }
        source = { network = { network = "default" } }
      },
    ]

    graphics = [{ vnc = { auto_port = true, listen = "127.0.0.1" } }]
  }
}

# The network hands out the address a few seconds after boot: wait for it.
resource "terraform_data" "wait_for_ip" {
  depends_on = [libvirt_domain.web]

  provisioner "local-exec" {
    command = "timeout 120 sh -c 'until virsh -c qemu:///system domifaddr ${libvirt_domain.web.name} --source lease | grep -q ipv4; do sleep 2; done'"
  }
}

# Ask libvirt which address the VM got.
data "libvirt_domain_interface_addresses" "web" {
  domain     = libvirt_domain.web.name
  source     = "lease"
  depends_on = [terraform_data.wait_for_ip]
}
