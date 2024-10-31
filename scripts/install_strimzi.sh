#!/bin/bash
STRIMZI_INSTALL_URL=$1
NAMESPACE=$2

echo "Creating namespace if it doesn't exist"
kubectl get namespace $NAMESPACE || kubectl create namespace $NAMESPACE

echo "Installing Strimzi Operator"
kubectl apply -f "$STRIMZI_INSTALL_URL" -n "$NAMESPACE"

echo "Waiting for Strimzi operator to be ready"
kubectl wait --for=condition=available --timeout=300s deployment/strimzi-cluster-operator -n "$NAMESPACE"
