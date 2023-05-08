
#
# TODO:
#   1.  Get the post processor working correctly. It's fucking late for me right now.  
#   2.  Change nfs mountpoint to just the whole proxmox thing and save the images there
#   2.  Build directory should be a local one
#   3.  create a vars file and set the values in there
#   4.  How can we do base images? Can we even do that? I don't think so.  So 
#       move things out of "base" images
#
packer {
  required_plugins {
    lxc = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/lxc"
    }
  }
}

locals {
  current_date_time = formatdate("YYYY-MM-DD-hh-mm-ss", timestamp())
  output_directory  = "/home/jpancoast/Stuff/image-builder-output/lxc/build_directory/alpine-base-314-amd64-${local.current_date_time}"
  version           = "3.17"
  image_directory   = "/home/jpancoast/Stuff/image-builder-output/lxc/containers/"
}

source "lxc" "alpine-base-314-amd64" {
  config_file      = "/etc/lxc/default.conf"
  template_name    = "download"
  output_directory = "${local.output_directory}"
  container_name   = "alpine-base-314-amd64"

  template_parameters = [
    "-d", "alpine",
    "-r", "${local.version}",
    "-a", "amd64"
  ]
}

#
# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/build
#
build {
  name    = "alpine-base-314-amd64"
  sources = ["source.lxc.alpine-base-314-amd64"]
  provisioner "shell" {
    inline = ["touch /blahblah"]
  }

  #  provisioner "shell-local" {
  #    environment_vars = ["TESTVAR=${build.PackerRunUUID}"]
  #    inline = [
  #      "echo source.name is ${source.name}.",
  #      "echo build.name is ${build.name}.",
  #      "echo build.PackerRunUUID is $TESTVAR"
  #    ]
  #  }

  post-processors {
    post-processor "shell-local" {
      inline = ["cd ${local.output_directory} ; gunzip rootfs.tar.gz ; tar -xf rootfs.tar ; cd rootfs ; tar -cf ${build.name}.tar * ; gzip ${build.name}.tar ; mv ${build.name}.tar.gz ${local.image_directory} ; rm -rf \"${local.output_directory}\""]
    }
  }
}
