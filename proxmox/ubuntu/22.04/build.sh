#!/bin/bash

source /home/jpancoast/bin/pm_token.sh

time packer build -var proxmox_api_password=$PM_API_TOKEN_SECRET -var proxmox_api_user=$PM_API_TOKEN_ID .
