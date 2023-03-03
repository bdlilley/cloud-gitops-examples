# redis-1region

### What this module creates

* single-region, 2az VPC
* elasticache redis cluster with tls and auth token
* eks cluster with 1 m5large node
* redis tester pod deployment

This module does not create public redis endpoints or VPN connections.  **To access redis in the cluster, use a shell in a pod.**

### Quickstart

Required env vars

```bash
export AWS_TF_BUCKET="your-aws-bucket-for-terraform-state"
export AWS_TF_REGION="your-aws-region-for-terraform-state"
export TF_STATE_KEY_PREFIX="your-team-name"
export TF_VAR_redis_auth="redis-token"
```

Init and Plan

```bash
cd terraform/redis-1region
./terraform-wrapper.sh init
./terraform-wrapper.sh plan
```

Create resources

```bash
./terraform-wrapper.sh apply --auto-approve
```

Add EKS to your local kubeconfig

```bash
# use cli to get cluster names
aws eks list-clusters
# use your cluster name to update kubeconfig
aws eks update-kubeconfig --name your-cluster-name
```

### Validate elasticache connection

The argocd aoa repo deploys a redis tester.  If the pod became ready it was able to set/get a key in elasticache:

```bash
kg pods -l app=redis-tester -n default
NAME                                            READY   STATUS    RESTARTS   AGE
aws-elasticache-redis-tester-854996ff6b-n72nr   1/1     Running   0          23s
```

```bash
k logs -l app=redis-tester -n default
9:52PM INF redis client created for master.solo-v0-redis-1region.sh5gsi.use2.cache.amazonaws.com:6379
9:52PM INF initial redis check OK
9:52PM INF starting container server on :8080
9:52PM DBG /liveness OK
9:52PM DBG /liveness OK
9:52PM DBG /liveness OK
```

### Cleanup

```bash
./terraform-wrapper.sh destroy --auto-approve
```
