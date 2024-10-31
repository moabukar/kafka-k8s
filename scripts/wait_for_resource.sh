#!/bin/bash
RESOURCE_TYPE=$1
RESOURCE_NAME=$2
NAMESPACE=$3

echo "Waiting for $RESOURCE_TYPE/$RESOURCE_NAME to be ready in namespace $NAMESPACE"
kubectl wait --for=condition=ready --timeout=300s $RESOURCE_TYPE/$RESOURCE_NAME -n "$NAMESPACE"
