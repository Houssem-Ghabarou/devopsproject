#!/bin/bash

echo "Installing Prometheus and Grafana monitoring stack..."

# Apply monitoring configurations
kubectl apply -f k8s/monitoring/prometheus-config.yaml
kubectl apply -f k8s/monitoring/prometheus-deployment.yaml
kubectl apply -f k8s/monitoring/grafana-datasources.yaml
kubectl apply -f k8s/monitoring/grafana-dashboards-config.yaml
kubectl apply -f k8s/monitoring/grafana-dashboards.yaml
kubectl apply -f k8s/monitoring/grafana-deployment.yaml

echo ""
echo "Waiting for Prometheus to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/prometheus -n devops-project

echo ""
echo "Waiting for Grafana to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/grafana -n devops-project

echo ""
echo "======================================"
echo "Monitoring stack installed successfully!"
echo "======================================"
echo ""
echo "Prometheus: http://localhost:30090"
echo "Grafana: http://localhost:30300"
echo ""
echo "Grafana credentials:"
echo "Username: admin"
echo "Password: admin"
echo ""
echo "You can also port-forward with:"
echo "kubectl port-forward svc/prometheus -n devops-project 9090:9090"
echo "kubectl port-forward svc/grafana -n devops-project 3000:3000"
echo ""
