
source "proxmox" "ubuntu" {
  iso_file                 = "${var.iso}"
  iso_storage_pool         = "synology-nas-storage:iso/"
  iso_checksum             = "sha512"
  node                     = "${var.proxmox_node_name}"
  token                    = "${var.proxmox_api_password}"
  username                 = "${var.proxmox_api_user}"
  proxmox_url              = "https://${var.proxmox_host}/api2/json"
  ssh_username             = "${var.ssh_username}"
  insecure_skip_tls_verify = true

  network_adapters {
    bridge = "vmbr0"
    model  = "virtio"
  }
  os = "l26"

  qemu_agent = false

  boot_command = ["${var.boot_command_prefix}", "/install/vmlinuz ", "auto ", "console-setup/ask_detect=false ", "debconf/frontend=noninteractive ", "debian-installer=${var.locale} ", "hostname=${var.hostname} ", "fb=false ", "grub-installer/bootdev=/dev/sda<wait> ", "initrd=/install/initrd.gz ", "kbd-chooser/method=us ", "keyboard-configuration/modelcode=SKIP ", "locale=${var.locale} ", "noapic ", "passwd/username=${var.ssh_username} ", "passwd/user-fullname=${var.ssh_fullname} ", "passwd/user-password=${var.ssh_password} ", "passwd/user-password-again=${var.ssh_password} ", "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${var.preseed_file} ", "-- <enter>"]
  boot_wait    = "10s"

  #  cores        = "${var.cores}"
  #  disks {
  #    cache_mode        = "writeback"
  #    disk_size         = "${var.disk_size}"
  #    format            = "raw"
  #    storage_pool      = "${var.datastore}"
  #    storage_pool_type = "${var.datastore_type}"
  #    type              = "scsi"
  #  }
  http_directory = "./http"
  #  memory                   = "${var.memory}"
  #  network_adapters {
  #    bridge = "vmbr0"
  #    model  = "virtio"
  #  }
  #  os                   = "l26"
  #  qemu_agent           = true
  #  sockets              = "${var.sockets}"
  #  ssh_password         = "${var.ssh_password}"
  #  ssh_timeout          = "90m"
  #  ssh_username         = "${var.ssh_username}"
  #  template_description = "${var.template_description}"
  #  unmount_iso          = true
  #  vm_id                = "${var.vmid}"
  #  vm_name              = "${var.template_name}"
}

# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/build
build {
  sources = ["source.proxmox.ubuntu"]

  provisioner "shell" {
    environment_vars = ["DEBIAN_FRONTEND=noninteractive"]
    inline           = ["date > provision.txt", "sudo apt-get update", "sudo apt-get -y upgrade", "sudo apt-get -y dist-upgrade", "sudo apt-get -y install linux-generic linux-headers-generic linux-image-generic", "sudo apt-get -y install qemu-guest-agent cloud-init", "sudo apt-get -y install procps iputils-ping telnet netcat mc wget curl dnsutils iproute2 vim tcpdump", "exit 0"]
    pause_before     = "20s"
  }

  #  post-processor "shell-local" {
  #    inline = ["ssh root@${var.proxmox_host} qm set ${var.vmid} --scsihw virtio-scsi-pci", "ssh root@${var.proxmox_host} qm set ${var.vmid} --ide2 ${var.datastore}:cloudinit", "ssh root@${var.proxmox_host} qm set ${var.vmid} --boot c --bootdisk scsi0", "ssh root@${var.proxmox_host} qm set ${var.vmid} --ciuser     ${var.ssh_username}", "ssh root@${var.proxmox_host} qm set ${var.vmid} --cipassword ${var.ssh_password}", "ssh root@${var.proxmox_host} qm set ${var.vmid} --vga std"]
  #  }
}
