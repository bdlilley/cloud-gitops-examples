# gm-1region

### What this module creates

* single-region, 2az VPC
* eks cluster with 1 m5large node
* common aws infra (ext-secrets, cert-manager, argocd, etc.)
* gloo mesh install (via argocd)

This module does not create public redis endpoints or VPN connections.  To access redis in the cluster, use a shell in a pod.

### Cleanup

```bash
./terraform-wrapper.sh destroy
```
