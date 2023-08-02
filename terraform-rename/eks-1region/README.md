# eks-1region

### What this module creates

* single-region, 2az VPC
* common infra components (ext-secrets, ext-dns, cert-manager, argocd, etc.)
* eks cluster with 1 m52xlarge node

### Cleanup

```bash
./terraform-wrapper.sh destroy
```
