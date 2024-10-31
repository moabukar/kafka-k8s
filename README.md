# 🚀 Kafka on K8s

## 🛠️ Setup & Testing

```bash
make cluster
make kafka-operator
make kafka-cluster
make topics

# Wait for the cluster to be ready before proceeding
make producer-create
make consumer-create

# Testing environment
make setup
make test
```

## 💬 Message Testing

```bash
# Start a producer session
kubectl exec -it kafka-producer -n kafka -- sh
bin/kafka-console-producer.sh --broker-list my-kafka-cluster-kafka-bootstrap:9092 --topic my-topic

# Example messages to send:
> Hello Kafka!
> This is a test message.

# In a different terminal, start a consumer session
kubectl exec -it kafka-consumer -n kafka -- sh
bin/kafka-console-consumer.sh --bootstrap-server my-kafka-cluster-kafka-bootstrap:9092 --topic my-topic --from-beginning

# The consumer will display all messages sent by the producer
```

## 🧪 Automated Testing

```bash
make test
```

## 🧹 Cleanup

```bash
make clean
```