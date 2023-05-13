variable "pm_user" {
  type        = string
  description = "Proxmox User Name"
}

variable "pm_pass" {
  type        = string
  description = "Proxmox User Password"
  default     = "packer"
}

variable "pm_token" {
  type        = string
  description = "Proxmox API Token"
}

variable "locale" {
  type    = string
  default = "en_US"
}

variable "hostname" {
  type    = string
  default = "ubuntu-testing"
}

variable "boot_command_prefix" {
  type    = string
  default = "<esc><esc><enter><wait>"
}
variable "ssh_user" {
  type        = string
  description = "SSH User"
  default     = "packer"
}

variable "preseed_file" {
  type    = string
  default = "preseed.cfg"
}

variable "ssh_pass" {
  type        = string
  description = "SSH Password"
  default     = "packer"
}

variable "vm_name" {
  type        = string
  description = "VM Name"
  default     = "packer_hostname"
}