
#
# Variable declarations
#
variable "docker_repository" {
  type        = string
  description = "Name of the docker repository"
  default     = "test_docker_repository"
}

variable "source_docker_image" {
  type        = string
  description = "Name of the docker image to use as the source image."
  default     = "amazonlinux"
}

variable "tags" {
  type        = list(string)
  description = "list of tags to add, other than 'latest' or a version number'"
  default     = []
}

variable "version" {
  type        = string
  description = "Container version"
  default     = "0.0.2"
}

#
# Packer config
#
packer {
  required_plugins {
    docker = {
      version = ">= 0.0.7"
      source  = "github.com/hashicorp/docker"
    }
  }
}

#
# Source container
#
source "docker" "amazon-linux-2" {
  image  = var.source_docker_image
  commit = true
}

#
# Build it!
#
build {
  sources = [
    "source.docker.amazon-linux-2",
  ]

  provisioner "ansible" {
    playbook_file = "../ansible/docker-playbook.yml"
  }

  post-processor "docker-tag" {
    repository = var.docker_repository
    tags       = concat(var.tags, [var.version], ["latest"])
  }
}

#
# TODO:
#   1. have it filter for the image
#       It doesn't look like this is possible.
#   2. How do I PULL from ECR? Do I put ecr_login and login_server in source.docker.amazon-linux-2?
#   3. Is there a way to make tagging easier?
#     DONE, just provide a list of tags in the 'tags' variable
#   4. How to push to ECR. Can't really test this yet
#


#
# How to PUSH to ECR:
# 
# post-processors {
#  post-processor "docker-tag" {
#      repository = "12345.dkr.ecr.us-east-1.amazonaws.com/packer"
#      tag = ["0.7"]
#  }
#  post-processor "docker-push" {
#      ecr_login = true
#      aws_access_key = "YOUR KEY HERE"
#      aws_secret_key = "YOUR SECRET KEY HERE"
#      login_server = "https://12345.dkr.ecr.us-east-1.amazonaws.com/"
#  }
#}

