packer {
  required_plugins {
    lxc = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/lxc"
    }
  }
}

{
  "builders": [
    {
      "type": "lxc",
      "name": "lxc-trusty",
      "config_file": "/tmp/lxc/config",
      "template_name": "ubuntu",
      "template_environment_vars": ["SUITE=trusty"]
    },
    {
      "type": "lxc",
      "name": "lxc-xenial",
      "config_file": "/tmp/lxc/config",
      "template_name": "ubuntu",
      "template_environment_vars": ["SUITE=xenial"]
    },
    {
      "type": "lxc",
      "name": "lxc-jessie",
      "config_file": "/tmp/lxc/config",
      "template_name": "debian",
      "template_environment_vars": ["SUITE=jessie"]
    },
    {
      "type": "lxc",
      "name": "lxc-centos-7-x64",
      "config_file": "/tmp/lxc/config",
      "template_name": "centos",
      "template_parameters": ["-R", "7", "-a", "x86_64"]
    }
  ]
}
