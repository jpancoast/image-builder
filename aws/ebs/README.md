# AWS-EBS Image Builder, now with added Ansible!

## Purpose
This is meant as a simple example for where to start a packer / ansible AMI build.

## Pre-requisites
* Ansible installed on build agent.
* packer installed on build agent.
* Python installed on base image.

## How to use it.
### The short of it:
* Configure the variables
* write Ansible roles / tasks that do the software installation / configuration work.
* run packer build

### Variable configuration
* Check variable_declarations.pkr.hcl for variables, descriptions, and default values. 
* create a pkrvars.hcl file to set and / or override the necessary defaults.
* Here's an example pkrvars.hcl file:
```
ami_owners = ["137112412989"]

ami_users = ["<account ID 1>", "<account ID 2>"]

region = "us-west-2"

ami_regions = ["us-east-1"]

ami_name_filter = "amzn2-ami-hvm-2.*"

root_device_type_filter = "ebs"

virtualization_type_filter = "hvm"

subnet_filters = {
  "tag:purpose" = "jpancoast-test-build"
}

tags = {
  "first_tag" = "This is the first tag."
  "second_tag" = "This is the second tag"
}

region_kms_key_ids = {
  "us-west-2" = "<key arn>"
  "us-east-1" = "<key arn>"
}
```

NOTES:
* If you want to encrypt the AMI's, set region_kms_key_ids, make sure they keys correspond to the region or regions in 'region' and 'ami_regions' list values.
* Only works with Customer Managed Keys right now. Should be simple to implement using AWS managed keys, but that's out of scope right now.

### Ansible
Packer calls the ansible provisioner in the build step. NOTE: This is the ansible REMOTE provisioner, so ansible is not required on the base image. The base image needs python installed. It takes the relative path of the ansible playbook.

This example playbook only calls one task. You can easily add more in the playbook file if needed.


### publish.sh
This is a simple example script meant to be expanded if necessary, for example if you need to take the AMI ID's and store them somewhere, you could modify publish.sh to do that work.

### Test scenarios
* single region, no encryption. SUCCESS
* single region, encryption. SUCCESS
* multiple regions, no encryption. SUCCESS
* multiple regions, encryption. SUCCESS

### Thoughts / TODOs
* Maybe make only option to encrypt AMI's, either with CMK or AWS managed key. TNO Philosophy!