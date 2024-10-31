#!/bin/bash

NAMESPACE=${1:-kafka}
HA_TOPIC="ha-test-topic"

echo "Creating highly available topic..."
kubectl exec -it kafka-producer -n $NAMESPACE -- \
    bin/kafka-topics.sh --create \
    --topic $HA_TOPIC \
    --bootstrap-server my-kafka-cluster-kafka-bootstrap:9092 \
    --partitions 3 --replication-factor 3

echo "Verifying topic configuration..."
kubectl exec -it kafka-producer -n $NAMESPACE -- \
    bin/kafka-topics.sh --describe \
    --topic $HA_TOPIC \
    --bootstrap-server my-kafka-cluster-kafka-bootstrap:9092

echo "Simulating broker failure..."
BROKER_POD="my-kafka-cluster-kafka-0"
kubectl delete pod $BROKER_POD -n $NAMESPACE

echo "Waiting for broker recovery..."
kubectl wait --for=condition=ready pod -l statefulset.kubernetes.io/pod-name=$BROKER_POD -n $NAMESPACE --timeout=300s

echo "Verifying topic health after recovery..."
kubectl exec -it kafka-producer -n $NAMESPACE -- \
    bin/kafka-topics.sh --describe \
    --topic $HA_TOPIC \
    --bootstrap-server my-kafka-cluster-kafka-bootstrap:9092

echo "HA test completed!"