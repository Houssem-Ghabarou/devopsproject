#!/bin/bash

# Script to install ArgoCD on Kubernetes cluster

echo "Installing ArgoCD..."

# Create ArgoCD namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
echo "Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Patch ArgoCD server service to use NodePort
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'

# Get the initial admin password
echo ""
echo "ArgoCD is installed!"
echo "================================"
echo "Getting ArgoCD initial admin password..."
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
echo "Username: admin"
echo "Password: $ARGOCD_PASSWORD"
echo ""

# Get ArgoCD server URL
NODEPORT=$(kubectl get svc argocd-server -n argocd -o jsonpath='{.spec.ports[0].nodePort}')
echo "ArgoCD Server: http://localhost:$NODEPORT"
echo ""
echo "You can also port-forward with:"
echo "kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo ""

# Apply the ArgoCD project and application
echo "Applying ArgoCD project and application..."
kubectl apply -f argocd/project.yaml
kubectl apply -f argocd/application.yaml

echo ""
echo "ArgoCD installation complete!"
echo "Access the UI and login with the credentials above."
