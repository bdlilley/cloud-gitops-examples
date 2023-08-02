#!/bin/bash

kubectl create ns argocd
kubectl apply -k ./argocd-install
kubectl apply -f ./argocd-apps
