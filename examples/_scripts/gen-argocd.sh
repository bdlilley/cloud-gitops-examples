#!/bin/bash

rm -rf .dist
mkdir -p .dist/argocd-install
mkdir -p .dist/argocd-apps

gomplate -d env=_env.yaml -d tf=.module-outputs.json -f ../_gomplates/argocd-apps.tmpl > .dist/argocd-apps/apps.yaml
gomplate -d env=_env.yaml -d tf=.module-outputs.json -f ../_gomplates/argocd-install.tmpl > .dist/argocd-install/kustomization.yaml
# gomplate -d tf=.module-outputs.json -f ../_gomplates/gp-install.tmpl > .dist/gp-install/kustomization.yaml
