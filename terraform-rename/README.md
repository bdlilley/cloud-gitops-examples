# terraform

This folder contains files common to all terraform modules.  They are included as symlinks in module folders.

This provides a simple means to keep terraform DRY without using clunky tools like terragrunt.

**_template**

Use to create new modules.  Make sure symlinks are preserved (`cp -R` on mac).

**terraform-wrapper.sh**

`terraform-wrapper.sh` is symlinked into each module folder (tf requires the module directory to be the current working dir).  The script sets up the state key and bucket and invokes terraform with common vars and module-specific vars.

The script ultimately passes all args on to `terraform`, so you can use any command without modifying the script.

**state keys**

State key and bucket are set by `terraform-wrapper.sh` on cli because tf doesn't support var interpolation in `backend` config blocks.  The script contains defaults for bucket, region, and key prefix that can be changed with env vars:

* `AWS_TF_BUCKET`
* `AWS_TF_REGION`
* `TF_STATE_KEY_PREFIX`

**common.tfvars**

Contains vars required for all modules, such as global tags for AWS resources.  You can also place module-specific vars here if they are to be shared with other modules.  This could also be done with remote state (import module A's remote state into module B), but it really doesn't matter when all the modules are co-located in the same repo such at this one.

**VERSION.txt**

`STACK_VERSION.txt` contains a version string that should be used (as a best practice) in **all** resouce names created by terraform.  This allows deployment and testing of different versions of infrastructure in parallel for testing or for creating new clean environments.