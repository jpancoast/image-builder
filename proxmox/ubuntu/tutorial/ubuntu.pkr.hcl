packer {
  required_plugins {
    proxmox = {
      version = " >= 1.0.1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

source "proxmox-iso" "proxmox-ubuntu-20" {
  proxmox_url = "https://proxmox.compnor.local:8006/api2/json"
  vm_name     = "packer-ubuntu-20"

  iso_file     = "synology-nas-storage:iso/ubuntu-22.04.2-live-server-amd64.iso"
  iso_checksum = "1b35a52bd32f5257b3454787c87688fdbe3fdd018a47ed2cf9a7cca71630f54230ceefd544cd984adf7593974b0087a9da2e51eaf9fea8a105ce86ef4be5fc76"

  username         = "${var.pm_user}"
  password         = "${var.pm_pass}"
  token            = "${var.pm_token}"
  node             = "proxmox"
  iso_storage_pool = "local"

  ssh_username           = "${var.ssh_user}"
  ssh_password           = "${var.ssh_pass}"
  ssh_timeout            = "20m"
  ssh_pty                = true
  ssh_handshake_attempts = 20

  boot_wait      = "5s"
  http_directory = "http" # Starts a local http server, serves Preseed file
  #  boot_command = [
  #    "<esc><wait><esc><wait><f6><wait><esc><wait>",
  #    "<bs><bs><bs><bs><bs>",
  #    "ip=${cidrhost("192.168.0.0/24", 9)}::${cidrhost("192.168.0.0/24", 1)}:${cidrnetmask("192.168.0.0/24")}::::${cidrhost("192.168.0.0/24", 1)}",
  #    "autoinstall ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/",
  #    "--- <enter>"
  #  ]

  boot_command = ["${var.boot_command_prefix}", "/install/vmlinuz ", "auto ", "console-setup/ask_detect=false ", "debconf/frontend=noninteractive ", "debian-installer=${var.locale} ", "hostname=${var.hostname} ", "fb=false ", "grub-installer/bootdev=/dev/sda<wait> ", "initrd=/install/initrd.gz ", "kbd-chooser/method=us ", "keyboard-configuration/modelcode=SKIP ", "locale=${var.locale} ", "noapic ", "passwd/username=${var.ssh_user} ", "passwd/user-fullname=${var.ssh_user} ", "passwd/user-password=${var.ssh_pass} ", "passwd/user-password-again=${var.ssh_pass} ", "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${var.preseed_file} ", "-- <enter>"]

  #"autoinstall ds=nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/",
  insecure_skip_tls_verify = true

  template_name        = "packer-ubuntu-20"
  template_description = "packer generated ubuntu-20.04.3-server-amd64"
  unmount_iso          = true

  pool       = "packer-builders"
  memory     = 4096
  cores      = 1
  sockets    = 1
  os         = "l26"
  qemu_agent = true
  disks {
    type         = "scsi"
    disk_size    = "30G"
    storage_pool = "local-lvm"
    #    storage_pool_type = "lvm"
    format = "raw"
  }
  network_adapters {
    bridge   = "vmbr0"
    model    = "virtio"
    firewall = true
  }
}

build {
  sources = ["source.proxmox-iso.proxmox-ubuntu-20"]
  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      "ls /"
    ]
  }
}