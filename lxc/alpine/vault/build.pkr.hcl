
#
# TODO:
#   4.  How can we do base images? Can we even do that? I don't think so.  So 
#       move things out of "base" images
#       Can I create like my own lxc registry?
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
  output_directory = "/tmp/lxc/build/${var.application}/${var.distribution}/${var.os_version}/${var.arch}/${var.image_version}"
}

source "lxc" "container" {
  config_file      = "/etc/lxc/default.conf"
  template_name    = "download"
  output_directory = "${local.output_directory}"
  container_name   = "${var.application}-${var.distribution}-${var.os_version}-${var.arch}-${var.image_version}"

  template_parameters = [
    "-d", "${var.distribution}",
    "-r", "${var.os_version}",
    "-a", "${var.arch}"
  ]
}

#
# a build block invokes sources and runs provisioning steps on them. The
# documentation for build blocks can be found here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/build
#
build {
  name    = "${var.application}-${var.distribution}-${var.os_version}-${var.arch}-${var.image_version}"
  sources = ["source.lxc.container"]

  #
  # Provision the base stuff (apk update, timezone, etc.)
  #
  provisioner "shell" {
    script = "${path.root}/../../../provisioning_scripts/${var.distribution}/base/provision.sh"

    env = {
      DNS_SEARCH_DOMAIN = var.dns_search_domain
      DNS_1             = var.dns_1
      DNS_2             = var.dns_2
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
      script = "${path.root}/../../../provisioning_scripts/base/post-processor-rearchive.sh"

      env = {
        OUTPUT_DIRECTORY = local.output_directory
        BUILD_NAME       = build.name
        IMAGE_DIRECTORY  = var.image_directory
      }
    }

    #
    # The new tgz file is now the actual artifact and we can nuke the previous old 'rootfs.tar.gz'
    #
    post-processor "artifice" { # tell packer this is now the new artifact
      files = ["${var.image_directory}/${build.name}"]
    }

    #
    # Clean up the original 'rootfs.tar.gz' artifact that's no longer needed
    #
    post-processor "shell-local" {
      script = "${path.root}/../../../provisioning_scripts/base/post-processor-clean.sh"

      env = {
        OUTPUT_DIRECTORY = local.output_directory
      }
    }
  }
}
