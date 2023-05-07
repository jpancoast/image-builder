# This file was autogenerated by the 'packer hcl2_upgrade' command. We
# recommend double checking that everything is correct before going forward. We
# also recommend treating this file as disposable. The HCL2 blocks in this
# file can be moved to other files. For example, the variable blocks could be
# moved to their own 'variables.pkr.hcl' file, etc. Those files need to be
# suffixed with '.pkr.hcl' to be visible to Packer. To use multiple files at
# once they also need to be in the same folder. 'packer inspect folder/'
# will describe to you what is in that folder.

# Avoid mixing go templating calls ( for example ```{{ upper(`string`) }}``` )
# and HCL2 calls (for example '${ var.string_value_example }' ). They won't be
# executed together and the outcome will be unknown.

# source blocks are generated from your builders; a source can be referenced in
# build blocks. A build block runs provisioner and post-processors on a
# source. Read the documentation for source blocks here:
# https://www.packer.io/docs/templates/hcl_templates/blocks/source
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

source "lxc" "ubuntu-xenial-amd64" {
  config_file = "/home/jpancoast/Stuff/code/image-builder/lxc/tutorial/ubuntu.lxc.conf"
  template_name = "download"
  output_directory = "/home/jpancoast/Stuff/image-builder-output/lxc/ubuntu-xenial-amd64-${local.current_date_time}"
  container_name = "ubuntu-xenial-amd64"
  
  template_parameters = [
          "-d", "ubuntu",
          "-r", "xenial",
          "-a", "amd64"
  ]
}

source "lxc" "alpine-314-amd64" {
  config_file = "/home/jpancoast/Stuff/code/image-builder/lxc/tutorial/alpine.lxc.conf"
  template_name = "download"
  output_directory = "/home/jpancoast/Stuff/image-builder-output/lxc/alpine-314-amd64-${local.current_date_time}"
  container_name = "alpine-314-amd64"
  
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
build {
  sources = ["source.lxc.alpine-314-amd64", "source.lxc.ubuntu-xenial-amd64"]
    provisioner "shell" {
      inline = ["touch /blahblah"]
    }

    provisioner "shell-local" {
    environment_vars = ["TESTVAR=${build.PackerRunUUID}"]
    inline = ["echo source.name is ${source.name}.",
              "echo build.name is ${build.name}.",
              "echo build.PackerRunUUID is $TESTVAR"]
  }
}
