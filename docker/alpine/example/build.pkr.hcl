source "docker" "example" {
  image  = "alpine"
  commit = true
}

build {
  sources = ["source.docker.example"]

  #
  # Provision the base stuff (apk update, timezone, etc.)
  #
  provisioner "shell" {
    script = "${path.root}/../../provisioning_scripts/${var.distribution}/base/provision.sh"

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
    post-processor "docker-tag" {
      repository = "${var.distribution}/${var.arch}/${var.application}"
      tags       = ["${var.version}", "latest"]
    }
    #    post-processor "docker-push" {}
  }
}
