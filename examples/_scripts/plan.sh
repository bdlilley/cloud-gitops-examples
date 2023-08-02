#!/bin/bash

terraform plan \
  -var-file ../common.tfvars \
  -var-file ./_my_vars.tfvars \
  -out plan.tfplan
