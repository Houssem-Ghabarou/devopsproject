# DevOps Mini Project - React Application

A complete DevOps project demonstrating containerization, CI/CD, Kubernetes deployment, GitOps with ArgoCD, and monitoring with Prometheus & Grafana.

## 📋 Table of Contents

- [Overview](#overview)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Application](#application)
- [Docker Setup](#docker-setup)
- [Kubernetes Deployment](#kubernetes-deployment)
- [CI/CD Pipeline](#cicd-pipeline)
- [Helm Charts](#helm-charts)
- [GitOps with ArgoCD](#gitops-with-argocd)
- [Monitoring](#monitoring)
- [Deployment Instructions](#deployment-instructions)
- [Accessing the Application](#accessing-the-application)

## 🎯 Overview

This project showcases a complete DevOps workflow including:

- **Application**: React single-page application with counter functionality
- **Containerization**: Docker multi-stage builds
- **Orchestration**: Kubernetes deployment on local cluster (Minikube/Kind)
- **CI/CD**: Jenkins pipeline with security scanning (Trivy)
- **Package Management**: Helm charts for Kubernetes deployments
- **GitOps**: ArgoCD for declarative deployments
- **Monitoring**: Prometheus and Grafana for observability

## 📁 Project Structure

```
DEVOPSPRJ/
├── src/                          # React application source code
│   ├── App.js
│   ├── App.css
│   ├── index.js
│   └── index.css
├── public/                       # Public assets
│   └── index.html
├── k8s/                          # Kubernetes manifests
│   ├── namespace.yaml
│   ├── configmap.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── ingress.yaml
│   ├── hpa.yaml
│   └── monitoring/               # Monitoring stack
│       ├── prometheus-config.yaml
│       ├── prometheus-deployment.yaml
│       ├── grafana-deployment.yaml
│       ├── grafana-datasources.yaml
│       ├── grafana-dashboards-config.yaml
│       ├── grafana-dashboards.yaml
│       └── install-monitoring.sh
├── helm/                         # Helm charts
│   └── react-app/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── deployment.yaml
│           ├── service.yaml
│           ├── configmap.yaml
│           ├── ingress.yaml
│           ├── hpa.yaml
│           ├── serviceaccount.yaml
│           ├── _helpers.tpl
│           └── NOTES.txt
├── argocd/                       # ArgoCD configurations
│   ├── application.yaml
│   ├── project.yaml
│   └── install.sh
├── monitoring/                   # Docker Compose monitoring
│   ├── prometheus.yml
│   └── grafana-datasources.yml
├── Dockerfile                    # Multi-stage Docker build
├── nginx.conf                    # Nginx configuration
├── docker-compose.yml            # Docker Compose setup
├── Jenkinsfile                   # Jenkins CI/CD pipeline
├── .gitlab-ci.yml                # GitLab CI alternative
├── package.json                  # Node.js dependencies
└── README.md                     # This file
```

## 🔧 Prerequisites

### Required Software

- **Docker** (v20.10+)
- **Docker Compose** (v2.0+)
- **Kubernetes Cluster**:
  - Minikube (v1.25+) OR
  - Kind (v0.11+) OR
  - k3s
- **kubectl** (v1.23+)
- **Helm** (v3.8+)
- **Node.js** (v18+) - for local development
- **Git**

### Optional

- **Jenkins** (for CI/CD)
- **ArgoCD** (for GitOps)
- **Docker Hub account** (for image registry)

## 🚀 Application

### React Counter Application

A simple React application demonstrating:
- Counter with increment/decrement functionality
- Real-time clock display
- Responsive design
- Environment variable integration

### Local Development

```bash
# Install dependencies
npm install

# Run development server
npm start

# Build for production
npm run build
```

## 🐳 Docker Setup

### Build Docker Image

```bash
# Build the image
docker build -t react-devops-app:latest .

# Run the container
docker run -p 3000:80 react-devops-app:latest

# Access: http://localhost:3000
```

### Docker Compose

Run the entire stack (app + monitoring):

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down
```

**Services:**
- React App: http://localhost:3000
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3001 (admin/admin)
- Node Exporter: http://localhost:9100

## ☸️ Kubernetes Deployment

### Setup Local Kubernetes Cluster

**Using Minikube:**

```bash
# Start Minikube
minikube start --cpus=4 --memory=8192 --driver=docker

# Enable addons
minikube addons enable ingress
minikube addons enable metrics-server
```

**Using Kind:**

```bash
# Create cluster
kind create cluster --name devops-cluster

# Install ingress controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
```

### Deploy Application

```bash
# Create namespace
kubectl apply -f k8s/namespace.yaml

# Apply all manifests
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/ingress.yaml
kubectl apply -f k8s/hpa.yaml

# Check deployment status
kubectl get all -n devops-project

# Check pod logs
kubectl logs -f deployment/react-app -n devops-project
```

### Scaling

```bash
# Manual scaling
kubectl scale deployment react-app --replicas=5 -n devops-project

# Auto-scaling is configured via HPA (2-10 replicas)
kubectl get hpa -n devops-project
```

## 🔄 CI/CD Pipeline

### Jenkins Pipeline

The Jenkinsfile includes:

1. **Checkout**: Clone source code
2. **Build**: Create Docker image
3. **Security Scan**: Trivy vulnerability scanning
4. **Test**: Run application tests
5. **Push**: Push to Docker Hub
6. **Deploy**: Update Kubernetes deployment

**Setup:**

```bash
# Configure Jenkins credentials
# 1. Add Docker Hub credentials (dockerhub-credentials)
# 2. Add Kubernetes config

# Update Jenkinsfile with your Docker Hub username
# DOCKER_IMAGE = 'your-dockerhub-username/react-devops-app'

# Create Jenkins pipeline job pointing to your repository
```

### GitLab CI

Alternative pipeline using GitLab CI/CD:

```bash
# Configure GitLab CI/CD variables:
# - CI_REGISTRY_USER
# - CI_REGISTRY_PASSWORD
# - KUBE_CONTEXT

# Pipeline runs automatically on push to main/master
```

## 📦 Helm Charts

### Install with Helm

```bash
# Add custom values (optional)
vim helm/react-app/values.yaml

# Install the chart
helm install react-app ./helm/react-app -n devops-project --create-namespace

# Upgrade the release
helm upgrade react-app ./helm/react-app -n devops-project

# Uninstall
helm uninstall react-app -n devops-project
```

### Customize Deployment

Edit `helm/react-app/values.yaml`:

```yaml
replicaCount: 3
image:
  repository: your-dockerhub-username/react-devops-app
  tag: latest
service:
  type: NodePort
  nodePort: 30080
```

## 🔁 GitOps with ArgoCD

### Install ArgoCD

```bash
# Run installation script
chmod +x argocd/install.sh
./argocd/install.sh

# Or manually:
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### Access ArgoCD UI

```bash
# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Port forward
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Login: https://localhost:8080
# Username: admin
# Password: [from above command]
```

### Deploy Application via ArgoCD

```bash
# Update repository URL in argocd/application.yaml
# repoURL: https://github.com/your-username/react-devops-app.git

# Apply ArgoCD application
kubectl apply -f argocd/project.yaml
kubectl apply -f argocd/application.yaml

# Check sync status
kubectl get applications -n argocd
```

## 📊 Monitoring

### Deploy Monitoring Stack

```bash
# Install Prometheus and Grafana
chmod +x k8s/monitoring/install-monitoring.sh
./k8s/monitoring/install-monitoring.sh

# Or manually:
kubectl apply -f k8s/monitoring/prometheus-config.yaml
kubectl apply -f k8s/monitoring/prometheus-deployment.yaml
kubectl apply -f k8s/monitoring/grafana-datasources.yaml
kubectl apply -f k8s/monitoring/grafana-dashboards-config.yaml
kubectl apply -f k8s/monitoring/grafana-dashboards.yaml
kubectl apply -f k8s/monitoring/grafana-deployment.yaml
```

### Access Monitoring Tools

**Prometheus:**
```bash
# NodePort: http://localhost:30090
# Or port-forward:
kubectl port-forward svc/prometheus -n devops-project 9090:9090
```

**Grafana:**
```bash
# NodePort: http://localhost:30300
# Or port-forward:
kubectl port-forward svc/grafana -n devops-project 3000:3000

# Credentials: admin/admin
```

### Grafana Dashboards

Pre-configured dashboards:
- **Kubernetes Cluster Monitoring**: Pod CPU/Memory usage
- **React Application Monitoring**: HTTP requests, response times, active pods

## 📝 Deployment Instructions

### Complete Deployment Workflow

1. **Setup Kubernetes Cluster**

```bash
# Using Minikube
minikube start --cpus=4 --memory=8192
minikube addons enable ingress metrics-server
```

2. **Build and Push Docker Image**

```bash
# Build image
docker build -t your-dockerhub-username/react-devops-app:latest .

# Login to Docker Hub
docker login

# Push image
docker push your-dockerhub-username/react-devops-app:latest
```

3. **Deploy Application**

```bash
# Option A: Using kubectl
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

# Option B: Using Helm
helm install react-app ./helm/react-app -n devops-project --create-namespace

# Option C: Using ArgoCD
./argocd/install.sh
kubectl apply -f argocd/application.yaml
```

4. **Deploy Monitoring**

```bash
./k8s/monitoring/install-monitoring.sh
```

5. **Verify Deployment**

```bash
# Check all resources
kubectl get all -n devops-project

# Check pod status
kubectl get pods -n devops-project -w

# Check logs
kubectl logs -f deployment/react-app -n devops-project
```

## 🌐 Accessing the Application

### Local Access

**Minikube:**
```bash
# Get Minikube IP
minikube ip

# Access via NodePort
http://$(minikube ip):30080

# Or use tunnel
minikube service react-app-service -n devops-project
```

**Kind:**
```bash
# Port forward
kubectl port-forward svc/react-app-service -n devops-project 8080:80

# Access: http://localhost:8080
```

### Add to /etc/hosts (for Ingress)

```bash
echo "$(minikube ip) react-app.local" | sudo tee -a /etc/hosts

# Access: http://react-app.local
```

## 🧪 Testing

### Health Checks

```bash
# Application health
curl http://localhost:30080/health

# Check from within cluster
kubectl run curl --image=curlimages/curl -i --rm --restart=Never -- curl http://react-app-service.devops-project.svc.cluster.local/health
```

### Load Testing

```bash
# Simple load test
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://react-app-service.devops-project.svc.cluster.local; done"

# Watch HPA scale
kubectl get hpa -n devops-project -w
```

## 🔒 Security

### Trivy Vulnerability Scanning

Integrated in CI/CD pipeline:

```bash
# Manual scan
trivy image your-dockerhub-username/react-devops-app:latest

# Generate report
trivy image --severity HIGH,CRITICAL --format json --output report.json your-dockerhub-username/react-devops-app:latest
```

## 🛠️ Troubleshooting

### Common Issues

**Pods not starting:**
```bash
kubectl describe pod <pod-name> -n devops-project
kubectl logs <pod-name> -n devops-project
```

**Image pull errors:**
```bash
# Verify image exists
docker pull your-dockerhub-username/react-devops-app:latest

# Check imagePullPolicy in deployment
kubectl get deployment react-app -n devops-project -o yaml | grep imagePullPolicy
```

**Service not accessible:**
```bash
# Check service
kubectl get svc -n devops-project

# Check endpoints
kubectl get endpoints -n devops-project

# Test from within cluster
kubectl run debug --image=curlimages/curl -i --rm --restart=Never -- curl http://react-app-service.devops-project.svc.cluster.local
```

## 📚 Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)

## 👥 Author

DevOps Team - Mini Project 2025-26

## 📄 License

This project is for educational purposes.
