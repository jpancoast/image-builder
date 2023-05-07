
packer {
  required_plugins {
    lxc = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/lxc"
    }
  }
}

locals {
  current_date_time = formatdate("YYYY-MM-DD:hh-mm-ss", timestamp())
}

source "lxc" "alpine-base-314-amd64" {
  config_file      = "/etc/lxc/default.conf"
  template_name    = "download"
  output_directory = "/home/jpancoast/Stuff/image-builder-output/lxc/base-images/alpine-base-314-amd64-${local.current_date_time}"
  container_name   = "alpine-base-314-amd64"

  template_parameters = [
    "-d", "alpine",
    "-r", "3.14",
    "-a", "amd64"
  ]
}

#
# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/build
#
build {
  name             = "alpine-base-314-amd64"
  sources = ["source.lxc.alpine-base-314-amd64"]
      provisioner "shell" {
        inline = ["touch /blahblah"]
      }

  provisioner "shell-local" {
    environment_vars = ["TESTVAR=${build.PackerRunUUID}"]
    inline = [
      "echo source.name is ${source.name}.",
      "echo build.name is ${build.name}.",
    "echo build.PackerRunUUID is $TESTVAR"
    ]
  }
}
