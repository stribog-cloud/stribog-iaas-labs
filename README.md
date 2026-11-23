# Stribog IaaS labs

Companion code for the **Stribog IaaS** video series: infrastructure as code on your own Linux machine with OpenTofu and libvirt/KVM. No cloud account, no cloud bill.

Each episode has its own folder. Every folder is self-contained: you can start at any episode.

| Folder | Episode |
|---|---|
| [`ep01/`](ep01/) | Provision, verify and destroy a VM with OpenTofu on KVM |

## What you need

- Linux on an x86-64 processor with hardware virtualization (KVM). Macs cannot run these labs. On Windows, use a Linux virtual machine with nested virtualization switched on.
- About 4 GiB of free memory, 15 GiB of free disk, and `sudo`.
- OpenTofu 1.13 or newer, libvirt and QEMU. The install commands shown in the video are in each episode's `setup/` folder.

## Safety

Every lab names what it creates with its episode prefix (for example `ep01-*`) and removes all of it with `tofu destroy`. Keys and state files are ignored by Git: the state file can hold secrets, so never commit it.

Ubuntu, OpenTofu, Terraform and HashiCorp are trademarks of their respective owners; this project is not affiliated with or endorsed by them.
