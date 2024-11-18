KIND_CLUSTER_NAME := kafka-cluster
KIND_CONFIG := kind-config.yaml
STRIMZI_INSTALL_URL := https://strimzi.io/install/latest?namespace=kafka
NAMESPACE := kafka
KUBECONFIG := $(HOME)/.kube/config

.PHONY: cluster kind-delete kafka-operator kafka-cluster topics producer-create consumer-create test setup clean

# Step 1: Create a kind cluster if it doesn't already exist
cluster:
	@echo "Checking if kind cluster exists"
	@if kind get clusters | grep -q $(KIND_CLUSTER_NAME); then \
		echo "Kind cluster $(KIND_CLUSTER_NAME) already exists, skipping creation."; \
	else \
		echo "Creating a kind cluster"; \
		kind create cluster --name $(KIND_CLUSTER_NAME) --config $(KIND_CONFIG); \
	fi

# Step 2: Delete kind cluster
kind-delete:
	@echo "Deleting the kind cluster"
	kind delete cluster --name $(KIND_CLUSTER_NAME)

# Step 3: Install Strimzi Operator and wait for readiness
kafka-operator: cluster
	@echo "Installing Strimzi Operator"
	bash scripts/install_strimzi.sh $(STRIMZI_INSTALL_URL) $(NAMESPACE)

# Step 4: Create Kafka cluster and wait for readiness
kafka-cluster: kafka-operator
	@echo "Creating Kafka cluster"
	kubectl apply -f kafka-cluster.yaml -n $(NAMESPACE)
	bash scripts/wait_for_resource.sh kafka my-kafka-cluster $(NAMESPACE)

# Step 5: Create Kafka topics
topics: kafka-cluster
	@echo "Creating Kafka topics"
	kubectl apply -f kafka-topics.yaml -n $(NAMESPACE)
	
# Step 6: Create Kafka producer pod
producer-create: topics
	@echo "Creating Kafka producer pod"
	kubectl apply -f kafka-producer.yaml -n $(NAMESPACE)
	bash scripts/wait_for_resource.sh pod kafka-producer $(NAMESPACE)

# Step 7: Create Kafka consumer pod
consumer-create: producer-create
	@echo "Creating Kafka consumer pod"
	kubectl apply -f kafka-consumer.yaml -n $(NAMESPACE)
	bash scripts/wait_for_resource.sh pod kafka-consumer $(NAMESPACE)

# Step 8: Run automated tests
test: consumer-create
	@echo "Running tests"
	bash scripts/test_consumer_producer.sh $(NAMESPACE)

perf-test:
	sh scripts/performance_test.sh

ha-test:
	sh scripts/ha_test.sh

monitor:
	@chmod +x scripts/monitoring-bootstrap.sh
	@./scripts/monitoring-bootstrap.sh

# Full setup
setup: kafka-operator kafka-cluster topics producer-create consumer-create test

setup-monitor: setup monitor

# Clean up the cluster
clean: kind-delete
	@echo "Cluster deleted!"
