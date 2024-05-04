
locals {
  subnets = cidrsubnets(var.cidr_block, 4, 4, 4, 4, 4, 4)

  split_subnets   = chunklist(local.subnets, length(local.subnets) / 2)
  private_subnets = local.split_subnets[0]
  public_subnets  = local.split_subnets[1]
}

variable "cidr_block" {
  type = string
}

provider "aws" {
  region = "us-west-2"
}

provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"
}

terraform {
  backend "s3" {
    bucket         = "jpancoast-iac-state-bucket-us-east-1-478122682220"
    encrypt        = true
    key            = "packer_testing/tf/network/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "jpancoast-iac-lock-table"
  }
}

module "network" {
  source = "../modules/network/"

  cidr_block      = var.cidr_block
  private_subnets = local.private_subnets
  public_subnets  = local.public_subnets

  tags = {
    purpose = "jpancoast-test-build"
  }
}

resource "aws_kms_key" "us-west-2" {
  description             = "KMS key us-west-2 for testing image build encryption"
  deletion_window_in_days = 7

  tags = {
    purpose = "jpancoast-test-build"
  }
}

resource "aws_kms_alias" "us-west-2" {
  name          = "alias/image-build-testing-key-us-west-2"
  target_key_id = aws_kms_key.us-west-2.key_id
}

resource "aws_kms_key" "us-east-1" {
  provider = aws.us-east-1

  description             = "KMS Key us-east-1 for testing image build encryption."
  deletion_window_in_days = 7

  tags = {
    purpose = "jpancoast-test-build"
  }
}

resource "aws_kms_alias" "us-east-1" {
  provider = aws.us-east-1

  name          = "alias/image-build-testing-key-us-east-1"
  target_key_id = aws_kms_key.us-east-1.key_id
}

output "module_network" {
  value = module.network
}
