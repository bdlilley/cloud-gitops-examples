#!/bin/bash

kubectl create ns argocd
kubectl apply -k .dist/argocd-install
kubectl apply -f .dist/argocd-apps
