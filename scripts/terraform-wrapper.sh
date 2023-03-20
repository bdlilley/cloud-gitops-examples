#!/bin/bash
#set -e

bucket="${AWS_TF_BUCKET:-bucket-terraform-000000000000}"
region="${AWS_TF_REGION:-us-east-2}"
keyPrefix="${TF_STATE_KEY_PREFIX:-myorg}"

# source a version text file to build the state key - this is also passed in as a variable to tf
# this is useful to test tf infrastructure changes without disrupting current environments
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source $SCRIPT_DIR/STACK_VERSION.txt

if [[ ${stackVersion} == "" ]]; then
    printf "stack version must be supplied via VERSION.txt\n"
    exit -1
fi

key="${keyPrefix}/${stackVersion}/${PWD##*/}/terraform.tfstate"

check () {
    printf "you are currently in the '${PWD##*/}' directory - please verify the bucket and state key:\n"
    printf "  bucket: ${bucket}\n"
    printf "  key: ${key}\n"
    printf "is this information correct? [y]: "
    read answer

    if [[ ${answer} != "" && ${answer} != "y" && ${answer} != "Y" ]]; then
        printf "exiting\n"
        exit 0
    fi
}

# when no params are provided, just print terraform usage and exit
if [ "$#" -eq 0 ]; then
    terraform
    exit 0
fi

backend="-backend-config=bucket=${bucket} -backend-config=key=${key}"
flags="-var-file _common.tfvars -var stackVersion=${stackVersion} -var moduleName=${PWD##*/} -var-file _module-vars.tfvars"

if [[ "$1" == "init" || "$1" == "apply" || "$1" == "destroy" ]]; then
    if [[ "$*" != *"--auto-approve"* ]]; then
        check
    fi
fi

if [ "$1" == "init" ]; then
    rm -rf .terraform/terraform.tfstate
    terraform $@ ${backend}
    exit $?
fi

if [ "$1" == "fmt" ]; then
    terraform $@
    exit $?
fi

if [ "$1" == "show" ]; then
    terraform $@
    exit $?
fi

if [ "$1" == "get" ]; then
    terraform $@
    exit $?
fi

if [[ "$1" == "plan" || "$1" == "apply" ]]; then
    terraform fmt
    if [ "$?" -ne 0 ]; then
        exit $?
    fi
    terraform $@ ${flags}
    exit $?
fi

if [ "$1" == "output" ]; then
    terraform $@
    exit $?
fi

terraform $@ ${flags}
