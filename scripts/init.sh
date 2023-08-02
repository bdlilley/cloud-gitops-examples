#!/bin/bash

source ../_scripts/colors.sh

printf "${BYellow}using state file $HOME/.terraform-state/${PWD##*/}/terraform.tfstate${NC}"

mkdir -p $HOME/.terraform-state/${PWD##*/}/

rm -rf .terraform/terraform.tfstate

terraform init \
  -var-file ../common.tfvars \
  -var-file ./_my_vars.tfvars \
  -backend-config=path="$HOME/.terraform-state/${PWD##*/}/terraform.tfstate"
