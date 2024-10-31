# Kafka on K8s

## Setup & Testing

```bash
make cluster
make kafka-operator
make kafka-cluster
make topics


## Needs some time to be ready
## Create producer and consumer
make producer-create
make consumer-create

## Testing
make setup

make test
```

## Test messages

```bash
kubectl exec -it kafka-producer -n kafka -- sh

bin/kafka-console-producer.sh --broker-list my-kafka-cluster-kafka-bootstrap:9092 --topic my-topic

> Hello Kafka!
> This is a test message.

## Different console

kubectl exec -it kafka-consumer -n kafka -- sh

bin/kafka-console-consumer.sh --bootstrap-server my-kafka-cluster-kafka-bootstrap:9092 --topic my-topic --from-beginning

Watch the messages: The consumer should now display the messages that were produced by the producer. You should see something like this:
```

## Teardown

```bash
make clean
```
