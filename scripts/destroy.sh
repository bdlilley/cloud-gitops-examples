#!/bin/bash


kubectl scale deployment argocd-server -n argocd --replicas=1
kubectl scale deployment argocd-repo-server -n argocd --replicas=1
kubectl scale deployment argocd-applicationset-controller -n argocd --replicas=1
kubectl scale statefulset argocd-application-controller -n argocd --replicas=1
kubectl delete ilm -A --all  --wait=false
kubectl delete glm -A --all --wait=false
kubectl delete iop -A --all  --wait=false
# kubectl delete svc -A --all  --wait=false

terraform destroy \
  -var-file ../common.tfvars \
  -var-file ./_my_vars.tfvars \
  --auto-approve
