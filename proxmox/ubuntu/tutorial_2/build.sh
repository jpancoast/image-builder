#!/bin/bash

source /home/jpancoast/bin/pm_token.sh

env | grep PM

packer build -var pm_api_token_secret=$PM_API_TOKEN_SECRET -var pm_api_token_id=$PM_API_TOKEN_ID .
