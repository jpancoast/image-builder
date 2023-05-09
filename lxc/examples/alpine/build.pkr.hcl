
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
  #  current_date_time = formatdate("YYYY-MM-DD-hh-mm-ss", timestamp())
  #  output_directory  = "/home/jpancoast/Stuff/image-builder-output/lxc/output_directory/alpine-base-${local.version}-amd64-${local.current_date_time}"
  output_directory = "/tmp/lxc/build/${local.distro}/${local.os_version}/${local.arch}/${local.image_version}"
  distro           = "alpine"
  arch             = "amd64"
  os_version       = "3.17"
  image_version    = "1.0.0"
  image_directory  = "/home/jpancoast/Stuff/proxmox/template/cache/"
}

source "lxc" "container" {
  config_file      = "/etc/lxc/default.conf"
  template_name    = "download"
  output_directory = "${local.output_directory}"
  container_name   = "${local.distro}-${local.os_version}-${local.arch}-${local.image_version}"

  template_parameters = [
    "-d", "${local.distro}",
    "-r", "${local.os_version}",
    "-a", "${local.arch}"
  ]
}

#
# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/build
#
build {
  name    = "${local.distro}-${local.os_version}-${local.arch}-${local.image_version}"
  sources = ["source.lxc.container"]

  provisioner "shell" {
    inline = [
      "echo 'search compnor.local' > /etc/resolv.conf",
      "echo 'nameserver 192.168.1.9' >> /etc/resolv.conf",
      "echo 'nameserver 192.168.1.6' >> /etc/resolv.conf",
      "cat /etc/resolv.conf",
      "echo update",
      "apk update",
      "echo upgrade",
      "apk upgrade -v",
      "apk add --no-cache tzdata",
      "echo 'US/Mountain' > /etc/timezone",
    ]
  }

  post-processors {
    post-processor "shell-local" {
      inline = [
        "ls -al ${local.output_directory}",
        "cd ${local.output_directory}",
        "gunzip rootfs.tar.gz",
        "tar -xf rootfs.tar",
        "cd rootfs",
        "tar -cf ${build.name}.tar *",
        "gzip ${build.name}.tar",
        "mv ${build.name}.tar.gz ${local.image_directory}"
      ]
    }

    post-processor "artifice" { # tell packer this is now the new artifact
      files = ["${local.image_directory}/${build.name}"]
    }

    post-processor "shell-local" {
      inline = [
        "rm -rf ${local.output_directory}"
      ]
    }
  }
  #  provisioner "shell-local" {
  #    environment_vars = ["TESTVAR=${build.PackerRunUUID}"]
  #    inline = [
  #      "echo source.name is ${source.name}.",
  #      "echo build.name is ${build.name}.",
  #      "echo build.PackerRunUUID is $TESTVAR"
  #    ]
  #  }

  #  post-processors {
  #    post-processor "shell-local" {
  #      inline = ["cd ${local.output_directory} ; gunzip rootfs.tar.gz ; tar -xf rootfs.tar ; cd rootfs ; tar -cf ${build.name}.tar * ; gzip ${build.name}.tar ; mv ${build.name}.tar.gz ${local.image_directory} ; rm -rf \"${local.output_directory}\""]
  #    }
  #  }
}
