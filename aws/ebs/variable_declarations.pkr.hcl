
#
# Variables
#   default values can be overridden in a pkrvars.hcl file, via cli, or other methods.
#

variable "ssh_username" {
  type        = string
  description = "ssh username for the VM. REQUIRED."
  default     = "ec2-user"
}

#
# ami_name_filter, root_device_type_filter, and virtualization_type_filter are used to build a filter to find the base image to use
#
variable "ami_name_filter" {
  type        = string
  description = "Search string for finding the AMI to use. REQUIRED."
  default     = "amzn2-ami-*"
}

variable "root_device_type_filter" {
  type        = string
  description = "What type of root device to find the base AMI. REQUIRED."
  default     = "ebs"
}

variable "virtualization_type_filter" {
  type        = string
  description = "Virtualization type to find the base AMI. REQUIRED."
  default     = "hvm"
}

variable "region" {
  description = "Region to build and save the image in. REQUIRED."
  type        = string
  default     = "us-west-2"
}

variable "ami_prefix" {
  description = "Prefix for the name of the image. REQUIRED. Should be different for each type of AMI (ie, if you're building an image with apache, maybe value shoudl be 'amzn-linux-2-apache'"
  type        = string
  default     = ""
}

variable "ami_owners" {
  type        = list(string)
  default     = ["137112412989"] #This is Amazon's ID
  description = "AWS Account ID of the owner of the base image you're starting from. REQUIRED."
}


variable "ami_users" {
  type        = list(string)
  description = "List of Account ID's that are allowed to use this image. OPTIONAL (only needed if you want to share this image to other accounts)"
  default     = null
}

variable "ami_regions" {
  description = "Regions to copy the AMI too. OPTIONAL. "
  type        = list(string)
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "map of additional tags for the AMI. OPTIONAL."
  default     = null
}

variable "assume_role_arn" {
  type        = list(string)
  description = "If you need to assume a role to do the build, put the ARN here. NOTE: This is a list because we want to build a dynamic block. Basically if this is set we create an 'assume_role' block. OPTIONAL (only needed if you need the build process to assume a role in another AWS account to do the build."
  default     = null
}

variable "skip_create_ami" {
  type        = bool
  description = "If set to true, an AMI is not created. Useful for testing. Default: false. OPTIONAL."
  default     = false
}

variable "subnet_filters" {
  type        = map(string)
  description = "Filters used to figure out what subnet should be used to build the Image. REQUIRED, set it in a pkrvars.hcl file."
  default     = null
}

variable "build_instance_type" {
  type        = string
  description = "Instance type packer launches to do it's work on. REQUIRED, default value is OK"
  default     = "t3.small"
}

variable "region_kms_key_ids" {
  type        = map(string)
  description = "Map of CMK KMS keys to use to encrypt the AMI in each region. Keys here MUST MATCH values in the 'ami_regions' list. OPTIONAL. Default: null"
  default     = null
}

variable "arch" {
  type        = string
  description = "Architecture of the image."
  default     = "x86_64"
}


#
# Locals
#
locals {
  timestamp     = regex_replace(timestamp(), "[- TZ:]", "")
  ami_name      = "${var.ami_prefix}-${local.timestamp}"
  external_id   = "${var.ami_prefix}-${local.timestamp}"
  session_name  = "${var.ami_prefix}-${local.timestamp}"
  base_ami_id   = data.amazon-ami.base_ami.id
  base_ami_name = data.amazon-ami.base_ami.name
  base_tags     = { "base_ami_id" = "${local.base_ami_id}", "base_ami_name" = "${local.base_ami_name}", "Name" = "${local.ami_name}" }
}
