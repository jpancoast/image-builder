#!/bin/bash

source /home/jpancoast/bin/pm_token.sh

env | grep PM

packer build -var pm_token=$PM_API_TOKEN_SECRET -var pm_user=$PM_API_TOKEN_ID .
