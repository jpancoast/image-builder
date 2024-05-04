packer {
  required_plugins {
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

data "amazon-ami" "base_ami" {
  filters = {
    name                = var.ami_name_filter
    root-device-type    = var.root_device_type_filter
    virtualization-type = var.virtualization_type_filter
  }

  most_recent = true
  owners      = var.ami_owners
  region      = var.region
}

source "amazon-ebs" "amzn2" {
  ami_name = local.ami_name

  instance_type   = var.build_instance_type
  skip_create_ami = var.skip_create_ami
  region          = var.region
  ssh_username    = var.ssh_username

  tags = merge(var.tags, local.base_tags)

  ami_regions        = var.ami_regions != null ? distinct(concat(var.ami_regions, [var.region])) : null
  region_kms_key_ids = var.ami_regions != null ? var.region_kms_key_ids : null
  encrypt_boot       = var.region_kms_key_ids != null ? true : false
  kms_key_id         = var.region_kms_key_ids != null ? var.region_kms_key_ids[var.region] : null

  subnet_filter {
    filters = var.subnet_filters

    most_free = true
    random    = false
  }

  source_ami = data.amazon-ami.base_ami.id

  dynamic "assume_role" {
    for_each = var.assume_role_arn == null ? [] : var.assume_role_arn

    content {
      role_arn     = element(var.assume_role_arn, 0)
      session_name = local.session_name
      external_id  = local.external_id
    }
  }
}

build {
  sources = [
    "source.amazon-ebs.amzn2",
  ]

  provisioner "ansible" {
    playbook_file = "../../ansible/vm-playbook.yml"
    use_proxy     = false

    extra_arguments = [
      "-vvvv"
    ]
  }

  post-processor "manifest" {
    strip_path = true
  }

  post-processor "shell-local" {
    environment_vars = [
      "AMI_PREFIX=${var.ami_prefix}",
      "BASE_AMI_NAME=${data.amazon-ami.base_ami.name}",
      "BASE_AMI_ID=${data.amazon-ami.base_ami.id}",
      "PACKER_MANIFEST=./packer-manifest.json",
      "APP_NAME=${var.ami_prefix}",
      "AMI_NAME=${local.ami_name}"
    ]

    execute_command = ["bash", "-c", "{{.Vars}} {{.Script}}"]
    script          = "./publish.sh"
  }
}
