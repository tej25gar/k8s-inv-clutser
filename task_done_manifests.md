# Task Done: Kubernetes Manifests

Date: 2026-05-14

## Completed
- Created `manifests/deployment.yaml` for NGINX deployment (`2` replicas).
- Created `manifests/service.yaml` exposing app as `LoadBalancer` on port `80`.
- Created optional `manifests/ingress.yaml` with host `nginx.example.com`.

## Apply Commands
```bash
kubectl apply -f manifests/
kubectl get pods
kubectl get svc
kubectl get ingress
```

## Notes
- `ingress.yaml` requires an installed ingress controller.
- Replace `nginx.example.com` with your real domain before DNS mapping.
