#!/bin/bash

NAMESPACE="kafka"
TOPIC="my-topic"
BROKER="my-kafka-cluster-kafka-bootstrap:9092"

# Retrieve producer and consumer pod names based on their labels
PRODUCER_POD=$(kubectl get pod -n $NAMESPACE -l app=kafka-producer -o jsonpath="{.items[0].metadata.name}" 2>/dev/null)
CONSUMER_POD=$(kubectl get pod -n $NAMESPACE -l app=kafka-consumer -o jsonpath="{.items[0].metadata.name}" 2>/dev/null)

# Check if producer and consumer pods were found
if [ -z "$PRODUCER_POD" ]; then
  echo "Error: Could not find producer pod. Check if it is running and labeled correctly (app=kafka-producer)."
  exit 1
fi

if [ -z "$CONSUMER_POD" ]; then
  echo "Error: Could not find consumer pod. Check if it is running and labeled correctly (app=kafka-consumer)."
  exit 1
fi

# Produce a test message and output it to the console
echo "Producing test message..."
PRODUCE_MESSAGE="Hello Kafka! This is a test message."
echo "Produced message: '$PRODUCE_MESSAGE'"
kubectl exec -n $NAMESPACE -it $PRODUCER_POD -- \
    sh -c "echo '$PRODUCE_MESSAGE' | bin/kafka-console-producer.sh --broker-list $BROKER --topic $TOPIC"

# Consume the message and output it to the console
echo "Consuming message..."
CONSUME_MESSAGE=$(kubectl exec -n $NAMESPACE -it $CONSUMER_POD -- \
    sh -c "timeout 5 bin/kafka-console-consumer.sh --bootstrap-server $BROKER --topic $TOPIC --from-beginning")

# Display the consumed message and check if it matches the produced message
echo "Consumed message: '$CONSUME_MESSAGE'"
if [[ "$CONSUME_MESSAGE" == *"$PRODUCE_MESSAGE"* ]]; then
    echo "Test passed: Message received by consumer."
else
    echo "Test failed: Consumer did not receive the message."
fi
