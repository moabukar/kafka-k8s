#!/bin/bash

echo -e '\n[BOOTSTRAPPING MONITORING]\n'

# Fails on errors
set -o errexit

##############################################
# Download helm repositories
##############################################
echo -e "\n[·] Downloading helm repositories..."

# Check if a helm repository exists and add it if it doesn't
function add_helm_repo() {
  local repo_name=$1
  local repo_url=$2
  if helm repo list | grep -q "$repo_name"; then
    echo "$repo_name repository already exists. Skipping..."
  else
    echo "Adding $repo_name repository..."
    helm repo add $repo_name $repo_url
  fi
}

# Add repositories
add_helm_repo traefik https://traefik.github.io/charts
add_helm_repo prometheus-community https://prometheus-community.github.io/helm-charts

helm repo update

##############################################
# Install Traefik
##############################################
echo -e "\n[·] Installing Traefik..."

helm upgrade --install \
  traefik traefik/traefik \
  --namespace traefik \
  --create-namespace \
  --wait

##############################################
# Install Prometheus Stack
##############################################
echo -e "\n[·] Installing Prometheus Stack..."

helm upgrade --install \
  prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --wait

##############################################
# Create IngressRoutes
##############################################
echo -e "\n[·] Creating IngressRoutes..."

# Create monitoring directory if it doesn't exist
mkdir -p monitoring

cat > monitoring/ingress-routes.yaml << 'EOF'
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: prometheus-http
  namespace: monitoring
spec:
  entryPoints:
    - web
  routes:
    - match: Host(`prometheus.127.0.0.1.nip.io`)
      kind: Rule
      services:
        - name: prometheus-kube-prometheus-prometheus
          port: 9090
---
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: grafana-http
  namespace: monitoring
spec:
  entryPoints:
    - web
  routes:
    - match: Host(`grafana.127.0.0.1.nip.io`)
      kind: Rule
      services:
        - name: prometheus-grafana
          port: 80
---
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: traefik-dashboard
  namespace: traefik
spec:
  entryPoints:
    - web
  routes:
    - match: Host(`traefik.127.0.0.1.nip.io`) && (PathPrefix(`/dashboard`) || PathPrefix(`/api`))
      kind: Rule
      services:
        - name: api@internal
          kind: TraefikService
EOF

kubectl apply -f monitoring/ingress-routes.yaml

##############################################
# Display access details
##############################################
echo -e "\n[·] Setup complete!"

echo -e "\n[💻] Access URLs:"
echo -e "Traefik Dashboard: http://traefik.127.0.0.1.nip.io/dashboard/"
echo -e "Prometheus: http://prometheus.127.0.0.1.nip.io"
echo -e "Grafana: http://grafana.127.0.0.1.nip.io"

echo -e "\n[🔐] Grafana Credentials:"
echo -e "Username: admin"
GRAFANA_PASSWORD=$(kubectl get secret prometheus-grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 --decode)
echo -e "Password: $GRAFANA_PASSWORD"

echo -e "\n✨ Done! Please wait a few minutes for all pods to start."