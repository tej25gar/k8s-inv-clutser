#!/usr/bin/env bash
set -eu pipefail

kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

kubectl apply --server-side --force-conflicts -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "ArgoCD installed in namespace argocd"
echo "Port-forward command: kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "Get admin password: kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 -d; echo"
