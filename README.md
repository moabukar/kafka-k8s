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

## Advanced

```bash
make monitor    # Set up monitoring
make perf-test  # Run performance tests
make ha-test    # Run high availability tests
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

## 📈 Performance Testing

```sh
# Test message throughput
hey -n 10000 -c 100 http://kafka-producer:9092/produce

# Monitor latency
kubectl exec -it kafka-producer -n kafka -- bin/kafka-producer-perf-test.sh \
    --topic my-topic \
    --num-records 100000 \
    --record-size 1000 \
    --throughput 10000 \
    --producer-props bootstrap.servers=my-kafka-cluster-kafka-bootstrap:9092
```

## 🧪 Partition Testing

```sh
# Create multi-partition topic
kubectl exec -it kafka-producer -n kafka -- bin/kafka-topics.sh \
    --create --topic multi-part-topic \
    --bootstrap-server my-kafka-cluster-kafka-bootstrap:9092 \
    --partitions 3 --replication-factor 1

# Test partition distribution
kubectl exec -it kafka-consumer -n kafka -- bin/kafka-consumer-groups.sh \
    --bootstrap-server my-kafka-cluster-kafka-bootstrap:9092 \
    --describe --group my-consumer-group
```

## 🧪 Replication Testing

```sh
# Create highly-available topic
kubectl exec -it kafka-producer -n kafka -- bin/kafka-topics.sh \
    --create --topic ha-topic \
    --bootstrap-server my-kafka-cluster-kafka-bootstrap:9092 \
    --partitions 3 --replication-factor 3

# Verify replicas
kubectl exec -it kafka-producer -n kafka -- bin/kafka-topics.sh \
    --describe --topic ha-topic \
    --bootstrap-server my-kafka-cluster-kafka-bootstrap:9092
```

## 🔧 Fault Tolerance 

```sh
# Test broker failure recovery
kubectl delete pod my-kafka-cluster-kafka-0 -n kafka
kubectl get pods -n kafka -w  # Watch recovery

# Test network partition simulation
kubectl patch networkpolicy kafka-network-policy -n kafka ...
```

## 📊 Monitoring & Metrics

```sh
# Deploy Prometheus & Grafana
kubectl apply -f monitoring/

# Access Kafka metrics
kubectl port-forward svc/prometheus-operated 9090:9090 -n monitoring
```

## 🧹 Cleanup

```bash
make clean
```

## TODO

- [ ] Get Monitoring to work
- [ ] Add Grafana dashboard for Kafka metrics
- [ ] Add more tests for fault tolerance and performance
- [ ] Add more tests for partition and replication
- [ ] Add more tests for monitoring and metrics
