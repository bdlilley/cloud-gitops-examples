#!/bin/bash

terraform apply plan.tfplan

terraform output -json > .module-outputs.json
