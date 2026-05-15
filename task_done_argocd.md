# Task Done: ArgoCD Setup

Date: 2026-05-15

## Completed in Repository
- Added `argocd/install.sh` to install ArgoCD in `argocd` namespace.
- Added `argocd/application.yaml` for GitOps sync of `manifests/`.

## Next Commands
Install ArgoCD:
```bash
cd k8s-inv-clutser
./argocd/install.sh
```

Access ArgoCD UI:
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Get initial admin password:
```bash
kubectl get secret argocd-initial-admin-secret \
  -n argocd \
  -o jsonpath="{.data.password}" | base64 -d; echo
```

Apply Application object:
```bash
kubectl apply -f argocd/application.yaml
kubectl get applications -n argocd
```

## Important
- Update `repoURL` in `argocd/application.yaml` to your real GitHub repository URL.
