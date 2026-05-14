

Create a complete CI/CD infrastructure pipeline on AWS using Terraform, Kubernetes, ArgoCD, and
optionally, Ingress + DNS.
Time line 1 to 2 days Maximum
✅Task Requirements
1. Provision AWS EKS Cluster using Terraform
- Use Terraform to:
- Create a VPC (optional: use EKS module with VPC support)
- Deploy an EKS Cluster
- Create IAM roles and node groups
- Output kubeconfig credentials to access the cluster.
2. Deploy an NGINX Application using a Kubernetes Manifest
- Create Kubernetes manifest files (YAML) for:
- Deployment
- Service (NodePort or ClusterIP)
- Apply the manifests using kubectl apply or sync using ArgoCD.
3. Set Up ArgoCD on EKS
- Install ArgoCD in the argocd namespace.
- Expose the ArgoCD server using a LoadBalancer or port-forward.
- Create an ArgoCD Application resource that points to a Git repository with the NGINX manifests.
4. Access the NGINX Application
- Show that NGINX is deployed and accessible via:
- kubectl port-forward OR
- LoadBalancer Service (optional)

5. (Optional Bonus) Expose NGINX via Ingress + Custom Domain
- Install an Ingress Controller (e.g., AWS ALB Ingress Controller or NGINX Ingress Controller).
- Create an Ingress resource for the NGINX application.
- Point a domain (can be a free domain or subdomain) to the Ingress IP using Route 53 or any DNS
provider.
- Provide screenshot or terminal output showing DNS resolution.
📁 Deliverables
GitHub Repository with:
- terraform/ folder: EKS cluster infrastructure code.
- manifests/ folder: Kubernetes manifests for NGINX.
- argocd/ folder: ArgoCD Application resource YAML.
- README.md with:
- Steps to provision the cluster
- ArgoCD login instructions
- Port-forward or public access URL for NGINX
- (Optional) Ingress domain details
💡 Evaluation Criteria
Criteria Description
Terraform Setup Modular, reusable code for EKS
Kubernetes Manifests Correct syntax, functional deployment
ArgoCD Usage GitOps principles properly applied
Accessibility NGINX accessible via port-forward or Ingress
Documentation Clear, reproducible steps in README
Bonus Ingress + DNS domain mapping (extra points)

AWS EKS + Terraform + ArgoCD + Kubernetes CI/CD Infrastructure
This is a strong real-world DevOps assignment.
With your background, you can complete this in 1–2 days if you keep the scope production-style but minimal.

Recommended Architecture

https://images.openai.com/static-rsc-4/FtuEp8H9ra20q5w6pbc3Zs-jKQhU7_pe7xg9YAlj-FPgEy4i20aId1aS_xVzPnKaF14l4Aq1UGfGYail8OTaPSKdT7683O6NnnZ0OPa9mOsORjfQUva5-3NUpva1oI1XWuG67cyCPgTHuIuHqGQsHNL4mEfyxKwz1Bg4-7qOcXtMbNoqQOeopTd7Y7e-dmr_?purpose=fullsize

https://images.openai.com/static-rsc-4/rFqEnqsUgTHZvuXpD1RslwbCSNWx7DAym5FkjF7RfghV37agWlLjcRYmBW-PBBNEwCCH_yXcOnYwK9Qz6G-ixmOWTkULrHANBXS2BP0ZM_73JFmTmWf_BGva2tRD7nl7lVDWP5Jj6DOek0H2TDHt6p0UZxrbQXEPQUmBfdo644e4uaxZ0d-KV_FJcgt2sXZs?purpose=fullsize

https://images.openai.com/static-rsc-4/aSsVg2mWEGZkRBJvIS_zcsJCl-Z7UcqwIiPtB6DjNuPIAf-MpRk4yHnPKfdEmOqn_6d115u2wbiRm0AUznevbB-R8x_9AtP2Q6QL0Hmeuc0ARJx9E--zArEQSWYdx1FWD6gucbg-c20lUcSDzAc89USfnGP-G_bVhvgWslueEMQQHLVdhnbZlnkwAGKlXUBP?purpose=fullsize
6
Final Flow
Developer Pushes Code
        ↓
GitHub Repository
        ↓
ArgoCD Watches Repo
        ↓
ArgoCD Syncs Kubernetes Manifests
        ↓
Amazon EKS Cluster
        ↓
NGINX Application Running
        ↓
Ingress / LoadBalancer
        ↓
Public Access
Recommended Repository Structure
eks-gitops-infra/
│
├── terraform/
│   ├── main.tf
│   ├── providers.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── eks.tf
│   ├── vpc.tf
│   ├── iam.tf
│   └── terraform.tfvars
│
├── manifests/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ingress.yaml
│
├── argocd/
│   ├── install.sh
│   └── application.yaml
│
├── screenshots/
│
└── README.md
1. Terraform – Provision EKS
Use the official Terraform EKS module from Terraform Registry EKS Module

providers.tf
provider "aws" {
  region = var.region
}

terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
variables.tf
variable "region" {
  default = "ap-south-1"
}

variable "cluster_name" {
  default = "devops-eks"
}
vpc.tf
Use official VPC module:

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "eks-vpc"

  cidr = "10.0.0.0/16"

  azs             = ["ap-south-1a", "ap-south-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}
eks.tf
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.30"

  subnet_ids = module.vpc.private_subnets
  vpc_id     = module.vpc.vpc_id

  enable_cluster_creator_admin_permissions = true

  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.medium"]

      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
  }
}
outputs.tf
output "cluster_name" {
  value = module.eks.cluster_name
}
Terraform Commands
terraform init
terraform plan
terraform apply -auto-approve
Configure kubectl
aws eks update-kubeconfig \
  --region ap-south-1 \
  --name devops-eks
Verify:

kubectl get nodes
2. Kubernetes Manifests – Deploy NGINX
deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-app
spec:
  replicas: 2

  selector:
    matchLabels:
      app: nginx-app

  template:
    metadata:
      labels:
        app: nginx-app

    spec:
      containers:
        - name: nginx
          image: nginx:latest

          ports:
            - containerPort: 80
service.yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service

spec:
  selector:
    app: nginx-app

  ports:
    - protocol: TCP
      port: 80
      targetPort: 80

  type: LoadBalancer
Apply:

kubectl apply -f manifests/
Verify:

kubectl get pods
kubectl get svc
3. Install ArgoCD
Official docs from ArgoCD Documentation

Install
kubectl create namespace argocd

kubectl apply -n argocd \
-f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
Expose ArgoCD
Option 1 – Port Forward
kubectl port-forward svc/argocd-server \
-n argocd 8080:443
Access:

https://localhost:8080
Get Admin Password
kubectl get secret argocd-initial-admin-secret \
-n argocd \
-o jsonpath="{.data.password}" | base64 -d
Username:

admin
4. ArgoCD Application
application.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application

metadata:
  name: nginx-app
  namespace: argocd

spec:
  project: default

  source:
    repoURL: https://github.com/YOUR_USERNAME/eks-gitops-infra.git
    targetRevision: HEAD
    path: manifests

  destination:
    server: https://kubernetes.default.svc
    namespace: default

  syncPolicy:
    automated:
      prune: true
      selfHeal: true
Apply:

kubectl apply -f argocd/application.yaml
5. Access NGINX
Using LoadBalancer
kubectl get svc nginx-service
You’ll get:

EXTERNAL-IP
Open in browser:

http://EXTERNAL-IP
Optional Bonus – Ingress + DNS
Install NGINX Ingress Controller
Official docs from Kubernetes NGINX Ingress Controller

kubectl apply -f \
https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/aws/deploy.yaml
ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress

metadata:
  name: nginx-ingress

spec:
  ingressClassName: nginx

  rules:
    - host: nginx.example.com

      http:
        paths:
          - path: /
            pathType: Prefix

            backend:
              service:
                name: nginx-service
                port:
                  number: 80
Apply:

kubectl apply -f manifests/ingress.yaml
DNS Mapping
If using Route53 from Amazon Route 53

Point:

nginx.example.com
to:

Ingress External IP / ALB DNS
Verify:

nslookup nginx.example.com
CI/CD Enhancement (Highly Recommended)
Add GitHub Actions.

Workflow
GitHub Push
   ↓
Terraform Validation
   ↓
Docker Build
   ↓
Push to ECR
   ↓
Update Kubernetes Manifest
   ↓
ArgoCD Auto Sync
Suggested README Sections
README Checklist
Infrastructure
Terraform version

AWS CLI setup

kubectl setup

IAM permissions

Deployment Steps
terraform init
terraform apply
aws eks update-kubeconfig
kubectl apply
ArgoCD Access
kubectl port-forward
Application Access
kubectl get svc
Cleanup
terraform destroy
Important Production-Level Improvements
Mention these in interview/discussion:

Security
IRSA

Security groups

Private EKS API

Secrets Manager

External Secrets Operator

Reliability
Multi-AZ node groups

Cluster Autoscaler

HPA

PodDisruptionBudget

Observability
Prometheus

Grafana

Loki

FluentBit

GitOps Best Practices
Separate infra and app repos

Helm charts

ArgoCD App of Apps

What Will Impress Evaluators Most
High Score Areas
1. Clean Terraform Structure
Use modules and variables properly.

2. ArgoCD Auto Sync
Enable:

selfHeal: true
prune: true
3. Proper README
Most candidates fail documentation.

4. Ingress + DNS
Huge bonus.

5. GitHub Actions
Even simple workflows add major value.

Suggested AWS Services Used
Amazon Web Services

Terraform

Kubernetes

Argo CD

NGINX

Estimated Timeline
Task	Time
Terraform EKS	3–4 hrs
Kubernetes manifests	30 mins
ArgoCD setup	1–2 hrs
Ingress + DNS	1–2 hrs
GitHub Actions	1 hr
README + testing	1–2 hrs
Total realistic completion:

8–12 hours
within your requested:

1–2 days
7

