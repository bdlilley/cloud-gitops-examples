# redis-1region

### What this module creates

* single-region, 2az VPC
* elasticache redis cluster with tls and auth token
* eks cluster with 1 m5large node
* redis tester pod deployment

This module does not create public redis endpoints or VPN connections.  To access redis in the cluster, use a shell in a pod.

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
./terraform-wrapper.sh destroy
```
