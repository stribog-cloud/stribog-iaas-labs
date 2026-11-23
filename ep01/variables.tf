variable "name" {
  description = "Prefix for every object this lab creates"
  type        = string
  default     = "ep01"
}

variable "base_image" {
  description = "Ubuntu cloud image, read-only backing file"
  type        = string
  default     = "/var/lib/libvirt/images/base/ubuntu-26.04-server-cloudimg-amd64.img"
}

variable "ssh_public_key_file" {
  description = "Public key installed for the stribog user"
  type        = string
  default     = "lab_key.pub"
}
