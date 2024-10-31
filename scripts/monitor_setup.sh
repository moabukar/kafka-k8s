#!/bin/bash

NAMESPACE=${1:-monitoring}

echo "Waiting for all pods to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=prometheus -n $NAMESPACE --timeout=300s

echo "Setting up port forwarding..."
kubectl port-forward svc/prometheus-grafana 3000:80 -n $NAMESPACE &
kubectl port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090 -n $NAMESPACE &

echo "Monitoring setup completed!"
echo "Access Grafana at: http://localhost:3000"
echo "Default credentials:"
echo "  Username: admin"
echo "  Password: prom-operator"
echo "Access Prometheus at: http://localhost:9090"