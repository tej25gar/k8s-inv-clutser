# Task Done: AWS ALB Ingress Controller

Date: 2026-05-15

## Completed in Repository
- Added `manifests/alb/ingressclass.yaml` for ALB ingress class.
- Added `manifests/alb/nginx-alb-ingress.yaml` for NGINX service via AWS ALB.

## Install AWS Load Balancer Controller
Set variables:
```bash
export CLUSTER_NAME=devops-eks
export AWS_REGION=ap-south-1
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
```

Associate IAM OIDC provider:
```bash
eksctl utils associate-iam-oidc-provider \
  --region "$AWS_REGION" \
  --cluster "$CLUSTER_NAME" \
  --approve
```

Create IAM policy:
```bash
curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
aws iam create-policy \
  --policy-name AWSLoadBalancerControllerIAMPolicy \
  --policy-document file://iam_policy.json
```

Create service account with IAM role:
```bash
eksctl create iamserviceaccount \
  --cluster "$CLUSTER_NAME" \
  --namespace kube-system \
  --name aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn arn:aws:iam::${AWS_ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve
```

Install controller using Helm:
```bash
helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName="$CLUSTER_NAME" \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region="$AWS_REGION"
```

Apply ALB ingress resources:
```bash
kubectl apply -f manifests/alb/ingressclass.yaml
kubectl apply -f manifests/alb/nginx-alb-ingress.yaml
```

Verify:
```bash
kubectl get pods -n kube-system | grep aws-load-balancer-controller
kubectl get ingress nginx-alb-ingress
```
