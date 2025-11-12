# Deployment Guide - Step by Step

This guide provides detailed step-by-step instructions for deploying the React DevOps application.

## Table of Contents

1. [Initial Setup](#initial-setup)
2. [Docker Deployment](#docker-deployment)
3. [Kubernetes Deployment](#kubernetes-deployment)
4. [CI/CD Setup](#cicd-setup)
5. [Monitoring Setup](#monitoring-setup)
6. [ArgoCD GitOps](#argocd-gitops)

---

## 1. Initial Setup

### 1.1 Prerequisites Installation

**Install Docker:**
```bash
# Ubuntu/Debian
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Verify
docker --version
```

**Install Minikube:**
```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Verify
minikube version
```

**Install kubectl:**
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Verify
kubectl version --client
```

**Install Helm:**
```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verify
helm version
```

### 1.2 Clone Repository

```bash
cd ~/Desktop/MINIPROJECTDEVOPS/DEVOPSPRJ
git init
git add .
git commit -m "Initial commit"
```

---

## 2. Docker Deployment

### 2.1 Local Testing with Docker

```bash
# Build the image
docker build -t react-devops-app:latest .

# Run container
docker run -d -p 3000:80 --name react-app react-devops-app:latest

# Test
curl http://localhost:3000
curl http://localhost:3000/health

# View logs
docker logs react-app

# Stop container
docker stop react-app
docker rm react-app
```

### 2.2 Docker Compose Deployment

```bash
# Start all services (app + monitoring)
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f react-app

# Access services:
# - React App: http://localhost:3000
# - Prometheus: http://localhost:9090
# - Grafana: http://localhost:3001 (admin/admin)

# Stop all services
docker-compose down
```

### 2.3 Push to Docker Hub

```bash
# Login to Docker Hub
docker login

# Tag image with your username
docker tag react-devops-app:latest YOUR_DOCKERHUB_USERNAME/react-devops-app:latest

# Push to registry
docker push YOUR_DOCKERHUB_USERNAME/react-devops-app:latest
```

**⚠️ Important:** Update the following files with your Docker Hub username:
- `k8s/deployment.yaml` (line 32)
- `helm/react-app/values.yaml` (line 5)
- `Jenkinsfile` (line 5)
- `argocd/application.yaml` (line 13)

---

## 3. Kubernetes Deployment

### 3.1 Start Minikube Cluster

```bash
# Start Minikube with sufficient resources
minikube start --cpus=4 --memory=8192 --driver=docker

# Enable required addons
minikube addons enable ingress
minikube addons enable metrics-server

# Verify cluster
kubectl cluster-info
kubectl get nodes
```

### 3.2 Method 1: Deploy with kubectl

```bash
# Create namespace
kubectl apply -f k8s/namespace.yaml

# Deploy application
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingress.yaml
kubectl apply -f k8s/hpa.yaml

# Verify deployment
kubectl get all -n devops-project
kubectl get pods -n devops-project -w

# Check deployment status
kubectl rollout status deployment/react-app -n devops-project

# View logs
kubectl logs -f deployment/react-app -n devops-project
```

### 3.3 Method 2: Deploy with Helm

```bash
# Install chart
helm install react-app ./helm/react-app \
  -n devops-project \
  --create-namespace \
  --set image.repository=YOUR_DOCKERHUB_USERNAME/react-devops-app \
  --set image.tag=latest

# Check release
helm list -n devops-project

# Get status
helm status react-app -n devops-project

# Upgrade if needed
helm upgrade react-app ./helm/react-app -n devops-project
```

### 3.4 Access the Application

**Option 1: NodePort**
```bash
# Get Minikube IP
minikube ip

# Access application
# http://<minikube-ip>:30080
```

**Option 2: Service Tunnel**
```bash
# Create tunnel
minikube service react-app-service -n devops-project

# This will open browser automatically
```

**Option 3: Port Forward**
```bash
# Forward local port to service
kubectl port-forward svc/react-app-service -n devops-project 8080:80

# Access: http://localhost:8080
```

**Option 4: Ingress**
```bash
# Add to /etc/hosts
echo "$(minikube ip) react-app.local" | sudo tee -a /etc/hosts

# Access: http://react-app.local
```

### 3.5 Verify Deployment

```bash
# Check all resources
kubectl get all -n devops-project

# Check pod details
kubectl describe pod <pod-name> -n devops-project

# Check service endpoints
kubectl get endpoints -n devops-project

# Test health endpoint
kubectl run curl --image=curlimages/curl -i --rm --restart=Never -- \
  curl http://react-app-service.devops-project.svc.cluster.local/health
```

---

## 4. CI/CD Setup

### 4.1 Jenkins Setup

**Install Jenkins (if not installed):**
```bash
# Using Docker
docker run -d -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --name jenkins \
  jenkins/jenkins:lts
```

**Configure Jenkins:**

1. Access Jenkins: http://localhost:8080
2. Get initial password: `docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword`
3. Install suggested plugins
4. Install additional plugins:
   - Docker Pipeline
   - Kubernetes CLI
   - Pipeline

**Add Credentials:**

1. Go to: Manage Jenkins → Manage Credentials
2. Add Docker Hub credentials:
   - ID: `dockerhub-credentials`
   - Username: Your Docker Hub username
   - Password: Your Docker Hub password
3. Add Kubernetes config (optional)

**Create Pipeline:**

1. New Item → Pipeline
2. Configure:
   - Pipeline definition: Pipeline script from SCM
   - SCM: Git
   - Repository URL: Your repository URL
   - Script Path: Jenkinsfile

3. Update `Jenkinsfile` with your Docker Hub username (line 5)

**Run Pipeline:**
```bash
# Trigger build manually or via webhook
# Pipeline will:
# 1. Build Docker image
# 2. Scan with Trivy
# 3. Run tests
# 4. Push to Docker Hub
# 5. Deploy to Kubernetes
```

### 4.2 GitLab CI Setup (Alternative)

**Configure GitLab CI/CD Variables:**

1. Go to: Settings → CI/CD → Variables
2. Add variables:
   - `CI_REGISTRY_USER`: Your Docker Hub username
   - `CI_REGISTRY_PASSWORD`: Your Docker Hub password
   - `KUBE_CONTEXT`: Kubernetes context (if deploying)

3. Commit `.gitlab-ci.yml` to repository

**Pipeline runs automatically on push to main/master**

---

## 5. Monitoring Setup

### 5.1 Deploy Prometheus and Grafana

```bash
# Make script executable
chmod +x k8s/monitoring/install-monitoring.sh

# Run installation
./k8s/monitoring/install-monitoring.sh

# Or manually:
kubectl apply -f k8s/monitoring/prometheus-config.yaml
kubectl apply -f k8s/monitoring/prometheus-deployment.yaml
kubectl apply -f k8s/monitoring/grafana-datasources.yaml
kubectl apply -f k8s/monitoring/grafana-dashboards-config.yaml
kubectl apply -f k8s/monitoring/grafana-dashboards.yaml
kubectl apply -f k8s/monitoring/grafana-deployment.yaml
```

### 5.2 Access Monitoring Tools

**Prometheus:**
```bash
# NodePort: http://<minikube-ip>:30090
minikube ip  # Get IP first

# Or port-forward:
kubectl port-forward svc/prometheus -n devops-project 9090:9090
# Access: http://localhost:9090
```

**Grafana:**
```bash
# NodePort: http://<minikube-ip>:30300
minikube ip  # Get IP first

# Or port-forward:
kubectl port-forward svc/grafana -n devops-project 3000:3000
# Access: http://localhost:3000

# Credentials: admin/admin
```

### 5.3 Configure Grafana

1. Login to Grafana (admin/admin)
2. Data source (Prometheus) should be auto-configured
3. Import dashboards:
   - Kubernetes Cluster Monitoring
   - React Application Monitoring

4. Create custom dashboards for:
   - Pod CPU/Memory usage
   - HTTP request rates
   - Application health

---

## 6. ArgoCD GitOps

### 6.1 Install ArgoCD

```bash
# Make script executable
chmod +x argocd/install.sh

# Run installation
./argocd/install.sh

# Or manually:
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for pods to be ready
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
```

### 6.2 Access ArgoCD UI

```bash
# Get initial password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d && echo

# Port forward
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Access: https://localhost:8080
# Username: admin
# Password: [from above command]
```

### 6.3 Configure Git Repository

**Update ArgoCD application configuration:**

Edit `argocd/application.yaml`:
```yaml
spec:
  source:
    repoURL: https://github.com/YOUR_USERNAME/YOUR_REPO.git  # Update this
    targetRevision: HEAD
    path: helm/react-app
```

### 6.4 Deploy Application via ArgoCD

```bash
# Apply ArgoCD project
kubectl apply -f argocd/project.yaml

# Apply ArgoCD application
kubectl apply -f argocd/application.yaml

# Check application status
kubectl get applications -n argocd

# Or via ArgoCD UI:
# 1. Login to ArgoCD
# 2. You should see "react-devops-app" application
# 3. Click "Sync" to deploy
```

### 6.5 Verify GitOps Workflow

```bash
# Check sync status
kubectl get application react-devops-app -n argocd

# View application details in UI
# Auto-sync is enabled, so changes to Git will auto-deploy

# Test auto-sync:
# 1. Edit helm/react-app/values.yaml (change replicas)
# 2. Commit and push
# 3. Watch ArgoCD sync automatically
```

---

## 7. Verification and Testing

### 7.1 Complete System Check

```bash
# Check all namespaces
kubectl get pods --all-namespaces

# Check devops-project namespace
kubectl get all -n devops-project

# Check ArgoCD
kubectl get all -n argocd
```

### 7.2 Application Testing

```bash
# Health check
curl http://$(minikube ip):30080/health

# Load application in browser
# http://$(minikube ip):30080
```

### 7.3 Monitoring Verification

```bash
# Check Prometheus targets
# http://$(minikube ip):30090/targets

# Check Grafana dashboards
# http://$(minikube ip):30300
```

### 7.4 Scaling Test

```bash
# Manual scale
kubectl scale deployment react-app --replicas=5 -n devops-project

# Watch pods
kubectl get pods -n devops-project -w

# Generate load (triggers HPA)
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- \
  /bin/sh -c "while sleep 0.01; do wget -q -O- http://react-app-service.devops-project.svc.cluster.local; done"

# Watch HPA
kubectl get hpa -n devops-project -w
```

---

## 8. Cleanup

### 8.1 Delete Application

```bash
# If deployed with kubectl
kubectl delete -f k8s/

# If deployed with Helm
helm uninstall react-app -n devops-project

# If deployed with ArgoCD
kubectl delete -f argocd/application.yaml
```

### 8.2 Delete Monitoring

```bash
kubectl delete -f k8s/monitoring/
```

### 8.3 Delete ArgoCD

```bash
kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl delete namespace argocd
```

### 8.4 Stop Minikube

```bash
minikube stop
minikube delete
```

---

## Troubleshooting

### Common Issues

**Issue: Image pull errors**
```bash
# Solution: Verify image exists and is public
docker pull YOUR_DOCKERHUB_USERNAME/react-devops-app:latest

# Or create image pull secret for private repos
kubectl create secret docker-registry regcred \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=YOUR_USERNAME \
  --docker-password=YOUR_PASSWORD \
  -n devops-project
```

**Issue: Pods in CrashLoopBackOff**
```bash
# Check logs
kubectl logs <pod-name> -n devops-project

# Describe pod
kubectl describe pod <pod-name> -n devops-project
```

**Issue: Service not accessible**
```bash
# Check service
kubectl get svc -n devops-project

# Check endpoints
kubectl get endpoints -n devops-project

# Test from within cluster
kubectl run debug --image=curlimages/curl -i --rm --restart=Never -- \
  curl http://react-app-service.devops-project.svc.cluster.local
```

---

## Next Steps

1. Configure SSL/TLS certificates
2. Setup persistent storage
3. Implement backup strategies
4. Add more comprehensive monitoring
5. Setup alerting with AlertManager
6. Implement blue-green or canary deployments
7. Add integration tests to CI/CD
8. Setup logging with ELK stack

---

**Congratulations! Your DevOps project is now fully deployed!** 🎉
