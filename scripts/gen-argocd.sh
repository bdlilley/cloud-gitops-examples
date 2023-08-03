#!/bin/bash

rm -rf .dist
mkdir -p .dist/argocd-install
mkdir -p .dist/argocd-resources

gomplate -d env=_env.yaml -d tf=.module-outputs.json -f ../../templates/argocd-infra-apps.tmpl > .dist/argocd-resources/infra-apps.yaml
gomplate -d env=_env.yaml -d tf=.module-outputs.json -f ../../templates/argocd-gloo-platform-apps.tmpl > .dist/argocd-resources/gloo-platform-apps.yaml
gomplate -d env=_env.yaml -d tf=.module-outputs.json -f ../../templates/argocd-install.tmpl > .dist/argocd-install/kustomization.yaml
gomplate -d env=_env.yaml -d tf=.module-outputs.json -f ../../templates/ilm.yaml > .dist/argocd-resources/ilm.yaml
gomplate -d env=_env.yaml -d tf=.module-outputs.json -f ../../templates/argocd-app-of-apps.tmpl > .dist/aoa.yaml

# gomplate -d tf=.module-outputs.json -f ../_gomplates/gp-install.tmpl > .dist/gp-install/kustomization.yaml
clusterarn=$(terraform output --json | jq -r '.eks_clean_arn.value')
rm -rf ../../argocd/generated/${clusterarn}
mkdir -p ../../argocd/generated/${clusterarn}

cp -rf .dist/argocd-resources/* ../../argocd/generated/${clusterarn}
git add -A ../../argocd/generated
git commit -a -m "generated ${clusterarn}"
git push