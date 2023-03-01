# Contributing

## Creating a new module

To create a new module, copy template: `cp -R ./terraform/_template ./terraform/your-new-module` (use -R to copy symlinks); `./scripts/terraform-wrapper.sh` uses the working dir of the module as part of the state key and resource name prefix so name your new module folder accordingly.

The template contains only the base providers and some common vars and patterns.  Add your own terraform files to the copied template.

## Terraform design patterns explained

See [./terraform/README.md](./terraform/README.md).