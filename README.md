# AWS EKS + Terraform + ArgoCD + NGINX GitOps Setup

This repository demonstrates an end-to-end DevOps assignment implementation:
- Infrastructure provisioning on AWS using Terraform
- Kubernetes application deployment (NGINX)
- GitOps continuous delivery using ArgoCD
- Optional ingress exposure using AWS Load Balancer Controller (ALB Ingress)

## 1. Project Structure

```text
k8s-inv-clutser/
├── terraform/                  # EKS + VPC infrastructure
├── manifests/                  # Kubernetes app manifests (NGINX)
├── argocd/                     # ArgoCD install and application config
└── README.md
```

## 2. What I Implemented

1. Provisioned AWS networking and EKS using Terraform modules.
2. Created Kubernetes manifests for NGINX deployment and service.
3. Added optional ingress manifest(s) for domain-based access.
4. Installed and configured ArgoCD for GitOps sync from repository.
5. Prepared AWS ALB Ingress Controller setup files and execution steps.

## 3. Prerequisites

- AWS account with sufficient IAM permissions for VPC, EKS, IAM, EC2, ELB.
- Installed tools: `terraform`, `aws`, `kubectl`, `helm`, `eksctl`.
- AWS credentials configured (`aws configure` or environment variables).

## 4. Step-by-Step Execution

## Step 1: Provision EKS using Terraform

```bash
cd terraform
terraform init
terraform plan
terraform apply -auto-approve
```

Key files:
- `providers.tf`: provider and version config
- `variables.tf`: reusable inputs
- `vpc.tf`: VPC module
- `eks.tf`: EKS module and managed node group
- `outputs.tf`: cluster outputs and kubeconfig command

## Step 2: Configure kubectl for EKS

```bash
aws eks update-kubeconfig --region ap-south-1 --name devops-eks
kubectl get nodes
```

Note: During setup, cluster endpoint was private-only initially, which blocked Lens access. It was updated to public endpoint for external client connectivity.

## Step 3: Deploy NGINX Application

```bash
kubectl apply -f manifests/
kubectl get pods
kubectl get svc
```

Implemented manifests:
- `manifests/deployment.yaml`: NGINX deployment (2 replicas)
- `manifests/service.yaml`: LoadBalancer service on port 80
- `manifests/ingress.yaml`: optional ingress definition

## Step 4: Install ArgoCD

```bash
./argocd/install.sh
```

If CRD annotation size error occurs, use server-side apply:

```bash
kubectl apply --server-side --force-conflicts -n argocd \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Access ArgoCD:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Login details:
- URL: `https://localhost:8080`
- Username: `admin`
- Password:

```bash
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d; echo
```

## Step 5: Configure ArgoCD Application

Either use UI (`NEW APP`) or apply manifest:

```bash
kubectl apply -f argocd/application.yaml
kubectl get applications -n argocd
```

Important configuration in ArgoCD app:
- Repository URL: your GitHub repo URL
- Path: `manifests`
- Revision: `master`
- Destination cluster: `https://kubernetes.default.svc`
- Namespace: `default`
- Sync Policy: Automatic (`Prune` + `Self Heal`)


## 5. Validation Performed

- `terraform init` and `terraform validate` completed successfully.
- NGINX manifests created and ready for apply/sync.
- ArgoCD manifests and install script prepared.
- ALB ingress resources prepared for controller-based exposure.

## 6. Cleanup

```bash
cd terraform
terraform destroy -auto-approve
```
