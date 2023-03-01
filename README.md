# cloud-gitops-examples

This repo serves two purposes:

* gitops tooling examples with terraform, argocd, etc.
* demonstrate various cloud topologies with gloo products

## Available Modules

|module|argo apps|description|
|---|---|---|
|[vpc-one-region](./terraform/vpc-one-region)| |1 region vpc|
|[vpc-two-region](./terraform/vpc-two-region)| |2 vpcs with peering|
|[redis-1region](./terraform/redis-1region)| |1 region vpc, elasticache single-node cluster with auth and tls, single-node eks cluster|
|[redis-2region](./terraform/redis-2region)|[values-aws-core-infra.yaml](./argocd/argocd-aoa/values-aws-core-infra.yaml) | [values-redis-tester.yaml](./argocd/argocd-aoa/values-redis-tester.yaml)|2 regions, 2 vpc, elasticache in 2-region global mode with tls and auth, single-node eks cluster in each region|
|[eks-1region](./terraform/eks-1region)|[values-aws-core-infra.yaml](./argocd/argocd-aoa/values-aws-core-infra.yaml)|1 region vpc, single-node eks cluster|

## Requirements

* terraform (I suggest https://tfswitch.warrensbox.com/ to manage versions)
* an AWS account with a working CLI env (can you `aws sts get-caller-identity`?)

## Environment for terraform state storage

State is stored in s3 (use a private encrypted bucket).

```bash
export AWS_TF_BUCKET="your-aws-bucket-for-terraform-state"
export AWS_TF_REGION="your-aws-region-for-terraform-state"
export TF_STATE_KEY_PREFIX="your-team-name"
```

## What is STACK_VERSION.txt?

It is a best practice to name resources in terraform with prefixes that allow multiple deployments of the same module.  Think of a collection of terraform modules (vpc, eks, redis, etc.) as an "infrastructure stack" that is defined with infrastructure as code (IaC).  Because it is "just code", it can be versioned.  Because it's versioned, multiple versions can be deployed in parallel.

The `STACK_VERSION.txt` file contains a string prefix that will be used on all aws resources.  This allows you to experiment with changes to infrastructure via terraform without breaking existing deployments, or simply to deploy the same module multiple times on the same account.  Use of a resource name prefix is NOT a terraform feature; care is taken by module developers to use input variables like stack version to name resources accordingly.

## Module-specific environment requirements

Some modules require additional env vars (like `redis_auth` in the redis modules).  View the README.md in the respective module folder, or simply run `./terraform-wrapper.sh init && ./terraform-wrapper.sh plan` in the module directory to learn what required vars are missing.  Any TF var can be automatically injected by setting env vars with the prefix `TF_VAR_` - for example `TV_VAR_redis_auth` would set the value for the `redis_auth` var.

## How to install a module

1. Validate your aws cli env with `aws sts get-caller-identity`
2. Change directory to the module you want to install `cd terraform/vpc-one-region`
3. Set bucket, region, and key prefix values:
    ```bash
    export AWS_TF_BUCKET="your-aws-bucket-for-terraform-state"
    export AWS_TF_REGION="your-aws-region-for-terraform-state"
    export TF_STATE_KEY_PREFIX="your-team-name"
    ```
4. Use `./terraform-wrapper.sh` to interact with terraform:
    ```bash
    ./terraform-wrapper.sh init
    ./terraform-wrapper.sh plan
    ```
5. Validate the terraform plan to be executed
6. Apply with `./terraform-wrapper.sh apply`

# Creating new modules

See [./CONTRIBUTING.md](./CONTRIBUTING.md)