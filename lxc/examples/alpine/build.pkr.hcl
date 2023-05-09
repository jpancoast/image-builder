
#
# TODO:
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
  output_directory  = "/tmp/lxc/build/${local.distro}/${local.os_version}/${local.arch}/${local.image_version}"
  distro            = "alpine"
  arch              = "amd64"
  os_version        = "3.17"
  image_version     = "1.0.0"
  image_directory   = "/home/jpancoast/Stuff/proxmox/template/cache/"
  dns_search_domain = "compnor.local"
  dns_1             = "192.168.1.6"
  dns_2             = "192.168.1.9"
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

  #
  # Provision the base stuff (apk update, timezone, etc.)
  #
  provisioner "shell" {
    script = "${path.root}/../../scripts/${local.distro}/base/provision.sh"

    env = {
      DNS_SEARCH_DOMAIN = local.dns_search_domain
      DNS_1             = local.dns_1
      DNS_2             = local.dns_2
    }
  }

  #
  # Now install the specific stuff ya want!
  #
  provisioner "shell" {
    script = "${path.root}/provision.sh"
  }

  post-processors {
    #
    # Fix the rootfs issue, re-archive the thing with proper directory structure
    #
    post-processor "shell-local" {
      script = "${path.root}/../../scripts/${local.distro}/base/post-processor-rearchive.sh"

      env = {
        OUTPUT_DIRECTORY = local.output_directory
        BUILD_NAME       = build.name
        IMAGE_DIRECTORY  = local.image_directory
      }
    }

    #
    # The new tgz file is now the actual artifact and we can nuke the previous old 'rootfs.tar.gz'
    #
    post-processor "artifice" { # tell packer this is now the new artifact
      files = ["${local.image_directory}/${build.name}"]
    }

    #
    # Clean up the original 'rootfs.tar.gz' artifact that's no longer needed
    #
    post-processor "shell-local" {
      script = "${path.root}/../../scripts/${local.distro}/base/post-processor-clean.sh"

      env = {
        OUTPUT_DIRECTORY = local.output_directory
      }
    }
  }
}
