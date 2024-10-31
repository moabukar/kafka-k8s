#!/bin/bash

NAMESPACE=${1:-kafka}
TOPIC="perf-test-topic"
NUM_MESSAGES=100000
MESSAGE_SIZE=1000
THROUGHPUT=10000

echo "Creating performance test topic..."
kubectl exec -it kafka-producer -n $NAMESPACE -- \
    bin/kafka-topics.sh --create \
    --topic $TOPIC \
    --bootstrap-server my-kafka-cluster-kafka-bootstrap:9092 \
    --partitions 3 --replication-factor 1

echo "Running producer performance test..."
kubectl exec -it kafka-producer -n $NAMESPACE -- \
    bin/kafka-producer-perf-test.sh \
    --topic $TOPIC \
    --num-records $NUM_MESSAGES \
    --record-size $MESSAGE_SIZE \
    --throughput $THROUGHPUT \
    --producer-props bootstrap.servers=my-kafka-cluster-kafka-bootstrap:9092

echo "Running consumer performance test..."
kubectl exec -it kafka-consumer -n $NAMESPACE -- \
    bin/kafka-consumer-perf-test.sh \
    --bootstrap-server my-kafka-cluster-kafka-bootstrap:9092 \
    --topic $TOPIC \
    --messages $NUM_MESSAGES

echo "Performance test completed!"